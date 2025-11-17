// FirebaseDreamService.swift
// Reverie
//
// Created by Neel Sani on 9/29/25.
//

import Firebase
import Foundation
import FirebaseStorage
import SwiftUI
import FirebaseFirestore

@Observable
class FirebaseDreamService {
    
    static let shared = FirebaseDreamService()
    let fb = FirebaseLoginService()
    
    func getDreams() async throws -> [DreamModel] {
        guard let userID = fb.currUser?.userID else {
            print("No current user found.")
            return []
        }
        
        let userDocRef = fb.db.collection("USERS").document(userID)
        let userDocument = try await userDocRef.getDocument()

        guard let data = userDocument.data(),
              let dreamKeys = data["dreams"] as? [String] else {
            print("User document does not contain a 'dreams' array.")
            return []
        }
        
        if dreamKeys.isEmpty {
            return [] // User has no dreams
        }
        
        print("Found \(dreamKeys.count) dream keys. Fetching in batches...")
        
        var allDreams: [DreamModel] = []
        let dreamsRef = fb.db.collection("DREAMS")
        
        // split dreamKeys into chunks of 30 (the Firestore limit)
        for i in stride(from: 0, to: dreamKeys.count, by: 30) {
            let chunk = Array(dreamKeys[i..<min(i + 30, dreamKeys.count)])
            
            if chunk.isEmpty { continue }
            
            print("Fetching batch \(i/30 + 1) (\(chunk.count) items)...")
            let query = dreamsRef.whereField("id", in: chunk)
            let snapshot = try await query.getDocuments()
            
            let batchDreams = snapshot.documents.compactMap { document -> DreamModel? in
                do {
                    return try document.data(as: DreamModel.self)
                } catch {
                    print("⚠️ Failed to decode dream \(document.documentID): \(error)")
                    return nil
                }
            }
            allDreams.append(contentsOf: batchDreams)
        }

        print("Fetched a total of \(allDreams.count) dreams.")
        
        return allDreams.sorted(by: { $0.date > $1.date })
    }
    
    func createDream(dream: DreamModel) async throws -> String {
        var newDream = dream
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let tagArray = dream.tags.map { $0.rawValue }
        
        print("USER ID: \(dream.userID)")
        
        let dreamData: [String: Any] = [
            "date": dream.date,
            "emotion": dream.emotion.rawValue,
            "generatedContent": dream.generatedContent,
            "title": dream.title,
            "image": [],
            "loggedContent": dream.loggedContent,
            "tags": tagArray,
            "userID": dream.userID,
            "finishedDream": dream.finishedDream,
        ]
        
        do {
            let ref = try await fb.db.collection("DREAMS").addDocument(data: dreamData)
            let dreamRef = ref.documentID
            print("Added Data with ref: \(dreamRef)")
            
            try await ref.updateData(["id": dreamRef])
            newDream.id = dreamRef

            let userRef = fb.db.collection("USERS").document(dream.userID)
            try await userRef.updateData([
                "dreams": FieldValue.arrayUnion([dreamRef])
            ])
            
            print("Appended \(dreamRef) to user \(dream.userID)")
            
            return dreamRef
        } catch {
            print("Error adding document: \(error)")
            throw error
        }
        
    }
    
    func createDreamWithImage(dream: DreamModel) async throws -> String {
        var newDream = dream
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let tagArray = dream.tags.map { $0.rawValue }
        
        print("USER ID: \(dream.userID)")
        
        let dreamData: [String: Any] = [
            "date": dream.date,
            "emotion": dream.emotion.rawValue,
            "generatedContent": dream.generatedContent,
            "title": dream.title,
            "loggedContent": dream.loggedContent,
            "tags": tagArray,
            "userID": dream.userID,
            "finishedDream": dream.finishedDream,
            "image": dream.image,
        ]
        
        do {
            let ref = try await fb.db.collection("DREAMS").addDocument(data: dreamData)
            let dreamRef = ref.documentID
            print("Added Data with ref: \(dreamRef)")
            
            try await ref.updateData(["id": dreamRef])
            newDream.id = dreamRef

            let userRef = fb.db.collection("USERS").document(dream.userID)
            try await userRef.updateData([
                "dreams": FieldValue.arrayUnion([dreamRef])
            ])
            
            print("Appended \(dreamRef) to user \(dream.userID)")
            
            return dreamRef
        } catch {
            print("Error adding document: \(error)")
            throw error
        }
        
    }
    
    func storeImages(dream: DreamModel, urls: [String]) async {
        do {
            try await self.fb.db.collection("DREAMS").document(dream.id).updateData(["image": urls])
        } catch {
            print("Firebase failed to add images to dream: \(error)")
        }
    }

    func fetchDream(dreamID: String) async throws -> DreamModel? {
        let dreamRef = self.fb.db.collection("DREAMS").document(dreamID)
        let document = try await dreamRef.getDocument()
        
        return try document.data(as: DreamModel.self)
    }
}

