//
//  FirebaseLoginServices.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/28/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Observation

@MainActor
@Observable
class FirebaseLoginService {
    static let shared = FirebaseLoginService()
    
    var currUser: UserModel?
    var userSession: FirebaseAuth.User?
    
    let auth = Auth.auth()
    let db = Firestore.firestore()
    
    var errorText: String? = nil
//    var isLoading: Bool = false
    
    init() {
        self.userSession = auth.currentUser

        Task {
            await fetchUser()
        }
    }
    
    func fetchUser() async {
        guard let uid = auth.currentUser?.uid else {return}
        var dreamModels: [DreamModel] = []

        guard let snapshot = try? await Firestore.firestore().collection("USERS").document(uid).getDocument() else { return }
        if snapshot.exists {
            if let userID = snapshot.get("userID") as? String,
               let name = snapshot.get("name") as? String,
               let username = snapshot.get("username") as? String,
               let overallAnalysis = snapshot.get("overallAnalysis") as? String,
               let dreams = snapshot.get("dreams") as? [String]
                
            {
                for dream in dreams {
                    guard let snapshot = try? await Firestore.firestore().collection("DREAMS").document(dream).getDocument() else { return }
                    if snapshot.exists {
                        if let userID = snapshot.get("userID") as? String,
                           let id = snapshot.get("id") as? String,
                           let title = snapshot.get("title") as? String,
                           let date = snapshot.get("date") as? String,
                           let loggedContent = snapshot.get("loggedContent") as? String,
                           let generatedContent = snapshot.get("generatedContent") as? String,
                           let tags = snapshot.get("tags") as? [String],
                           let image = snapshot.get("image") as? String,
                           let emotion = snapshot.get("emotion") as? String
                           
                           
                        {
                            let dateF: Date = {
                                if let ts = snapshot.get("date") as? Timestamp {
                                    return ts.dateValue()
                                } else {
                                    return Date()
                                }
                            }()
                            let tagF: [DreamModel.Tags] = tags.compactMap { DreamModel.Tags(rawValue: $0.lowercased()) }
                            let emotionF: DreamModel.Emotions = DreamModel.Emotions(rawValue: emotion.lowercased()) ?? .neutral

                            let dreamModel = DreamModel(userID: userID, id: id, title: title, date: dateF, loggedContent: loggedContent, generatedContent: generatedContent, tags: tagF, image: image, emotion: emotionF)
                            dreamModels.append(dreamModel)
                            
                        }
                    }
                    
                }

                let user = UserModel(name: name, userID: userID, username: username, overallAnalysis: overallAnalysis, dreams: dreamModels)

                self.currUser = user

            }
        }
    }
    
    
    func createUser(withEmail email: String, password: String, name: String) async {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = UserModel( name: name, userID: result.user.uid, username: email, overallAnalysis: "Not enough dreams for an overall analysis", dreams: [])
            let userData: [String: Any] = [
                "userID": user.userID,
                "name": user.name,
                "username": user.username,
                "overallAnalysis": user.overallAnalysis,
                "dreams": user.dreams

            ]
            try await Firestore.firestore().collection("USERS").document(user.userID).setData(userData)
            await fetchUser()

        } catch {
            let message = parseFirebaseError(error)
            self.errorText = message
            print("Create user error: \(error.localizedDescription)")
        }
    }
    
    func signIn(withEmail email: String, password: String) async {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            let message = parseFirebaseError(error)
            self.errorText = message
            print("Sign in error: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.userSession = nil
            self.currUser = nil
            print("Sign out successful.")
        } catch let signOutError {
            print("Error signing out: %@", signOutError)
            self.errorText = "Failed to sign out."
        }
    }

    private func parseFirebaseError(_ error: Error) -> String {
        let errorCode = (error as NSError).code
        switch errorCode {
            case AuthErrorCode.invalidEmail.rawValue:
                return "Invalid email address."
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return "The email address is already in use."
            case AuthErrorCode.weakPassword.rawValue:
                return "The password is too weak. Please use a stronger password."
            case AuthErrorCode.wrongPassword.rawValue:
                return "Incorrect password. Please try again."
            case AuthErrorCode.userNotFound.rawValue:
                return "No account found with this email."
            case AuthErrorCode.networkError.rawValue:
                return "A network error occurred. Please check your internet connection."
            default:
                print("Unhandled Auth Error: \(error.localizedDescription)")
                return "An unexpected error occurred. Please try again."
        }
    }
}

