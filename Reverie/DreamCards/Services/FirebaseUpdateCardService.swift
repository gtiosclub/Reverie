//
//  FirebaseUpdateCard.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/28/25.
//

import FirebaseStorage
import FirebaseFirestore
import UIKit

class FirebaseUpdateCardService {
    static let shared = FirebaseUpdateCardService()
    let fb = FirebaseLoginService()
    
    func toggleIsUnlocked(card: CardModel) async {
        do {
            try await self.fb.db.collection("DREAMCARDS").document(card.id).updateData(["isUnlocked": !card.isUnlocked])
        } catch {
            print("Firebase failed to toggle isUnlocked with error: \(error)")
        }
    }
    
    func toggleIsPinned(card: CardModel) async {
        do {
            try await self.fb.db.collection("DREAMCARDS").document(card.id).updateData(["isPinned": !card.isPinned])
        } catch {
            print("Firebase failed to toggle isPinned with error: \(error)")
        }
    }
}
