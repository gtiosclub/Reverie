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

extension Notification.Name {
    static let didLoginAndLoadUser = Notification.Name("didLoginAndLoadUser")
}

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
            FirebaseDCService.shared.generateDummyImage()
        }
    }
    
    func fetchUser() async {
        guard let uid = auth.currentUser?.uid else { return }

        var dreamModels: [DreamModel] = []
        var dreamCards: [CardModel] = []

        do {
            let userDoc = try await Firestore.firestore().collection("USERS").document(uid).getDocument()
            guard userDoc.exists else { return }

            guard let userID = userDoc.get("userID") as? String,
                  let name = userDoc.get("name") as? String,
                  let username = userDoc.get("username") as? String,
                  let overallAnalysis = userDoc.get("overallAnalysis") as? String,
                  let dreams = userDoc.get("dreams") as? [String] else {
                return
            }

            func parseDate(from value: Any?) -> Date {
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d/yy"
                formatter.locale = Locale(identifier: "en_US_POSIX")

                switch value {
                case let dateString as String:
                    if let parsed = formatter.date(from: dateString) {
                        return parsed
                    }
                    return Date()

                case let timestamp as Timestamp:
                    return timestamp.dateValue()

                case let date as Date:
                    return date

                default:
                    return Date()
                }
            }

            for dreamID in dreams {
                let dreamDoc = try await Firestore.firestore().collection("DREAMS").document(dreamID).getDocument()
                guard dreamDoc.exists else { continue }

                guard let userID = dreamDoc.get("userID") as? String,
                      let id = dreamDoc.get("id") as? String,
                      let title = dreamDoc.get("title") as? String,
                      let loggedContent = dreamDoc.get("loggedContent") as? String,
                      let generatedContent = dreamDoc.get("generatedContent") as? String,
                      let tags = dreamDoc.get("tags") as? [String],
                      let image = dreamDoc.get("image") as? [String],
                      let emotion = dreamDoc.get("emotion") as? String else {
                    continue
                }

                let dateF = parseDate(from: dreamDoc.get("date"))
                let tagF: [DreamModel.Tags] = tags.compactMap { DreamModel.Tags(rawValue: $0.lowercased()) }
                let emotionF: DreamModel.Emotions = DreamModel.Emotions(rawValue: emotion.lowercased()) ?? .neutral
                let finishedDream = dreamDoc.get("finishedDream") as? String ?? "None"

                let dreamModel = DreamModel(
                    userID: userID,
                    id: id,
                    title: title,
                    date: dateF,
                    loggedContent: loggedContent,
                    generatedContent: generatedContent,
                    tags: tagF,
                    image: image,
                    emotion: emotionF,
                    finishedDream: finishedDream
                )

                dreamModels.append(dreamModel)
            }

            do {
                dreamCards = try await FirebaseDCService.shared.fetchDCCards(userID: userID)
                let achievements = try await AchievementsService.shared.fetchUnlockedAchievements(userID: userID)
                let unlockedAchievements = achievements.filter { $0.isAchievementUnlocked }
                dreamCards.append(contentsOf: unlockedAchievements)
            } catch {
                print("Failed to get DC Cards: \(error.localizedDescription)")
            }

            let user = UserModel(
                name: name,
                userID: userID,
                username: username,
                overallAnalysis: overallAnalysis,
                dreams: dreamModels,
                dreamCards: dreamCards
            )

            self.currUser = user
            NotificationCenter.default.post(name: .didLoginAndLoadUser, object: nil)

        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
    }
    
    
    func createUser(withEmail email: String, password: String, name: String) async {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = UserModel( name: name, userID: result.user.uid, username: email, overallAnalysis: "Not enough dreams for an overall analysis", dreams: [], dreamCards: [])
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

