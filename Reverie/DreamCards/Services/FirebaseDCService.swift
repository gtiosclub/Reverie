//
//  FirebaseDCService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/12/25.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

@MainActor
@Observable
class FirebaseDCService {
    static let shared = FirebaseDCService()
    
    let fb = FirebaseUserService()
    
    let dcfms = DCFoundationModelService()
    
    let igs = ImageGenerationService()
    
    func createDC(card: CardModel) async {
        print("USER ID: \(card.userID)")
        
        do {
            try fb.db.collection("DREAMCARDS").document(card.id).setData(from: card)
            
            print("Added Data with ref: \(card.id)")
            
            let userRef = fb.db.collection("USERS").document(card.userID)
            
            try await userRef.updateData([
                "dreamcards": FieldValue.arrayUnion([card.id])
            ])
            print("Appended \(card.id) to user \(card.userID)")
        } catch {
            print("Error adding document: \(error)")
        }
    }
}
