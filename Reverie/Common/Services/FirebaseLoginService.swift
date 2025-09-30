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
    
    let auth = Auth.auth()
    let db = Firestore.firestore()
    
    var errorText: String? = nil
    var isLoading: Bool = false
    
    private init() {}

    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorText = nil
        
        do {
            print("Creating user in Auth")
            let authResult = try await auth.createUser(withEmail: email, password: password)
            let user = authResult.user
            print("Auth user created successfully with UID: \(user.uid)")
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            print("Display name updated")
            
            let userid = user.uid
            
            print("Attempting to set data in Firestore")
            try await db.collection("USERS").document(userid).setData([
                "username": email,
                "name": name,
                "dreams": [],
                "userID": userid,
                "overallAnalysis": ""
            ])
            print("Firestore data set successfully")
            
        } catch {
            print("--- ❌ ERROR ---")
            print("Error during sign up: \(error.localizedDescription)")
            self.errorText = parseFirebaseError(error)
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorText = nil
        
        do {
            // Sign in the user
            try await auth.signIn(withEmail: email, password: password)
            print("Sign in successful.")
            
        } catch {
            // If sign in fails, catch the error.
            print("Error during sign in: \(error)")
            self.errorText = parseFirebaseError(error)
        }
        
        isLoading = false
    }

    func signOut() {
        do {
            try auth.signOut()
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
