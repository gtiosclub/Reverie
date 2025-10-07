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
    let emotionsModelSession = FoundationModel.emotionsModelSession
    
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
    
    func getRecommendedTags(dreamText: String) async throws -> [DreamModel.Tags] {
        do {
            let response = try await tagsModelSession.respond(to: dreamText)
            let data = response.content.data(using: .utf8)!
            let tags = try JSONDecoder().decode([DreamModel.Tags].self, from: data)
            return tags
        } catch {
            print(error)
            return []
        }
    }
    
    func getEmotion(dreamText: String) async throws -> DreamModel.Emotions {
        do {
            let response = try await emotionsModelSession.respond(to: dreamText)
            let content = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

            if let emotion = DreamModel.Emotions(rawValue: content) {
                return emotion
            }
            
            return .neutral
        } catch {
            print(error)
            return .neutral
        }
    }
}
