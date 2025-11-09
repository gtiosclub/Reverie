//
//  Achievements.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/4/25.
//

import SwiftUI
import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import Firebase

@MainActor
class AchievementsService {
    static let shared = AchievementsService()
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    let fb = FirebaseLoginService()

    private let achievements: [CardModel] = [
        CardModel(
            userID: "achievements",
            id: "1dream",
            name: "Dreamy",
            description: "You logged your first dream!",
            image: "1dream",
            cardColor: .pink
        ),
        CardModel(
            userID: "achievements",
            id: "50dreams",
            name: "Dream Chaser",
            description: "You logged 50 dreams!",
            image: "50dreams",
            cardColor: .blue
        ),
        CardModel(
            userID: "achievements",
            id: "100dreams",
            name: "Visionary",
            description: "You logged 100 dreams!",
            image: "100dreams",
            cardColor: .purple
        ),
        CardModel(
            userID: "achievements",
            id: "7daystreak",
            name: "Lunar Cycle",
            description: "You logged dreams for seven nights straight!",
            image: "7daystreak",
            cardColor: .yellow
        ),
    ]
    
    func uploadAllAchievements() async {
        for card in achievements {
            do {
                guard let image = UIImage(named: card.image!) else {
                    print("⚠️ Could not find image named \(card.image)")
                    continue
                }
                
                let url = try await uploadAchievementImage(image, id: card.id)
                
                try await db.collection("ACHIEVEMENTS").document(card.id).setData([
                    "userID": card.userID,
                    "id": card.id,
                    "name": card.name,
                    "description": card.description,
                    "image": url.absoluteString,
                    "cardColor": card.cardColor.rawValue
                ])
                
                print("✅ Uploaded \(card.name)")
            } catch {
                print("❌ Failed to upload \(card.name): \(error.localizedDescription)")
            }
        }
    }
    
    private func uploadAchievementImage(_ image: UIImage, id: String) async throws -> URL {
        guard let data = image.pngData() else {
            throw NSError(domain: "ImageError", code: 0)
        }
        let ref = storage.child("dream_achievements/\(id).png")
        _ = try await ref.putDataAsync(data)
        return try await ref.downloadURL()
    }
    
    func checkAndUnlockAchievements(dreamCount: Int, dreamStreak: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("USERS").document(uid)
        
        // already unlocked achievements
        let doc = try? await userRef.collection("UNLOCKED_ACHIEVEMENTS").getDocuments()
        let unlockedIDs = Set(doc?.documents.compactMap { $0.documentID } ?? [])
        
        // thresholds
        let thresholds: [(id: String, condition: Bool)] = [
            ("7day", dreamStreak >= 7),
            ("1dream", dreamCount >= 1),
            ("50dreams", dreamCount >= 50),
            ("100dreams", dreamCount >= 100)
        ]
        
        for (id, condition) in thresholds {
            guard condition, !unlockedIDs.contains(id) else { continue }
            await unlockAchievementForCurrentUser(id: id)
        }
    }
    
    func unlockAchievementForCurrentUser(id: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userRef = Firestore.firestore().collection("USERS").document(uid)
        let unlockedRef = userRef.collection("UNLOCKED_ACHIEVEMENTS").document(id)

        // already unlocked?
        let existing = try? await unlockedRef.getDocument()
        if existing?.exists == true { return }

        guard let card = try? await getAchievement(id: id) else {
            print("failed to fetch global achievement \(id)")
            return
        }

        try? await unlockedRef.setData([
            "userID": card.userID,
            "id": card.id,
            "name": card.name,
            "description": card.description,
            "image": card.image ?? "",
            "cardColor": card.cardColor.rawValue,
            "isShown": false,
            "isUnlocked": false,
            "isPinned": false,
            "isAchievementUnlocked": true
        ])

        print("user \(uid) unlocked achievement \(id)")
    }
    
    func getAchievement(id: String) async throws -> CardModel? {
        let db = Firestore.firestore()
        
        let doc = try await db.collection("achievements").document(id).getDocument()
    
        guard let data = doc.data() else {
            print("no data found for achievement ID:", id)
            return nil
        }
        
        let colorString = (data["cardColor"] as? String) ?? "pink"
        let cardColor = CardModel.DreamColor(rawValue: colorString) ?? .pink
        
        let userID = data["userID"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let image = data["image"] as? String ?? ""
        
        return CardModel(
            userID: userID,
            id: id,
            name: name,
            description: description,
            image: image,
            cardColor: cardColor
        )
    }
    
    func fetchUnlockedAchievements() async throws -> [CardModel] {
        print("Fetching unlocked achievements")
        guard let userID = fb.currUser?.userID else { return [] }

        let userDocRef = fb.db.collection("USERS").document(userID)
        let achievementsCollection = userDocRef.collection("UNLOCKED_ACHIEVEMENTS")
        let snapshot = try await achievementsCollection.getDocuments()

        var unlockedAchievements: [CardModel] = []

        for doc in snapshot.documents {
            do {
                let achievement = try doc.data(as: CardModel.self)
                unlockedAchievements.append(achievement)
            } catch {
                print("Failed to decode achievement \(doc.documentID): \(error)")
            }
        }
        return unlockedAchievements
    }
    
    func fetchUnlockedAchievements(userID: String) async throws -> [CardModel] {
        print("Fetching unlocked achievements")

        let userDocRef = fb.db.collection("USERS").document(userID)
        let achievementsCollection = userDocRef.collection("UNLOCKED_ACHIEVEMENTS")
        let snapshot = try await achievementsCollection.getDocuments()

        var unlockedAchievements: [CardModel] = []

        for doc in snapshot.documents {
            do {
                let achievement = try doc.data(as: CardModel.self)
                unlockedAchievements.append(achievement)
            } catch {
                print("Failed to decode achievement \(doc.documentID): \(error)")
            }
        }
        return unlockedAchievements
    }
}
