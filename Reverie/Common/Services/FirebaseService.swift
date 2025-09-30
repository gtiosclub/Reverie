//
//  FirebaseService.swift
//  Reverie
//
//  Created by Nithya Ravula on 9/26/25.
//

import Foundation
import Firebase
import FoundationModels

public class FirebaseService {
    let db = Firebase.db
    let tagsModelSession = FoundationModel.tagsModelSession
    
    func getUserInfo() async throws -> [String] {
        let userRef = db.collection("USERS").document("OtAj4vL9Xzz8lsm4nCuL")
        print("Fetching document…")
        let snapshot = try await userRef.getDocument()
        guard let data = snapshot.data() else {
            print("No data in snapshot")
            return []
        }
        print("Document data: \(data)")
        if let dreams = data["dreams"] as? [String] {
            return dreams
        } else if let dreams = data["dreams"] as? [Any] {
            return dreams.compactMap { $0 as? String }
        }
        return []
    }
    
    func getRecommendedTags(dreamText: String) async throws -> Void {
        let response = try await tagsModelSession.respond(to: dreamText)
        print(response.content) // needs to be changed to return (whatever gives the array of strings)
    }
}
