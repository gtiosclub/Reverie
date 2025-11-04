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
    
    func setIsPinned(card: CardModel, isPinned: Bool) async {
        do {
            try await self.fb.db.collection("DREAMCARDS").document(card.id).updateData(["isPinned": isPinned])
        } catch {
            print("Firebase failed to toggle isPinned with error: \(error)")
        }
    }
    
    func setIsShown(card: CardModel, isShown: Bool) async {
        do {
            try await self.fb.db.collection("DREAMCARDS").document(card.id).updateData(["isShown": isShown])
        } catch {
            print("Firebase failed to toggle isUnlocked with error: \(error)")
        }
    }
}
