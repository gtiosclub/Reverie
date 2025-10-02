//
//  FirebaseService.swift
//  Reverie
//
//  Created by Nithya Ravula on 9/26/25.
//

import Foundation
import Firebase

public class FirebaseService {
    let db = Firebase.db
    
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
    
    
    func createDream(dream: DreamModel) async {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        //create array of tag strings
        var tagArray: [String] = []
        
        for tag in dream.tags {
            tagArray.append(tag.rawValue)
        }
        
        print("USER ID: \(dream.userId)")
        
        do {
            let ref = try await db.collection("DREAMS").addDocument(data: [
                "date": dateFormatter.string(from: dream.date),
                "emotion": String(describing: dream.emotion),
                "generatedContent": dream.genereatedContent,
                "id": dream.id,
                "image": dream.image,
                "loggedContent": dream.loggedContent,
                "tags": tagArray,
                "userID": dream.userId
            ])
            let dreamRef = ref.documentID
            print("Added Data with ref: \(dreamRef)")
            
            let userRef = try await db.collection("USERS").document(dream.userId)
            
            try await userRef.updateData([
                "dreams": FieldValue.arrayUnion([dreamRef])
                ])
            
            print("Appended \(dreamRef) to user \(dream.userId)")
            
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    
}
