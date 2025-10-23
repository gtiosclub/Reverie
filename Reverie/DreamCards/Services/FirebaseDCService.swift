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
import FirebaseAuth

@Observable
class FirebaseDCService {
    static let shared = FirebaseDCService()
    
    let fb = FirebaseLoginService()
    
    let dcfms = DCFoundationModelService()
    
    let igs = ImageGenerationService()
    
    func generateImage(for dream: DreamModel) {
        Task.detached(priority: .utility) {
            do {
                let character = try await self.dcfms.getCharacterPrompt(dreamText: dream.loggedContent)
                print("Prompt generated: \(character)")
                
                if character.count == 3 {
                    let prompt = character[0]
                    let name = character[1]
                    let description = character[2]
                    
                    print("Prompt: \(prompt)")
                    print("Name: \(name)")
                    print("Description: \(description)")
                    
                    guard let sticker = try await self.igs.generateSticker(prompt: prompt) else {
                        print("Failed to generate sticker image")
                        return
                    }
                    print("Sticker image generated.")
                    
                    let stickerURL = try await FirebaseStorageService.shared.uploadSticker(
                      sticker,
                      forUserID: dream.userID,
                      dreamID: dream.id
                    )
                    print("Sticker uploaded with URL: \(stickerURL.absoluteString)")
                    
                    await self.createDC(card: CardModel(userID: dream.userID, id: dream.id, name: name, description: description, image: stickerURL.absoluteString, cardColor: .purple))
                }
            } catch {
                print("Failed to get character details: \(error)")
            }
        }
    }
    
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
    
    func fetchDCCards() async throws -> [CardModel] {
        guard let userID = fb.currUser?.userID else {
            print("User not logged in, cannot fetch cards.")
            return []
        }
        
        // fetch the user's document to get the list of card IDs
        let userDocRef = fb.db.collection("USERS").document(userID)
        let userDocument = try await userDocRef.getDocument()
        
        guard let data = userDocument.data(),
              let cardIDs = data["dreamcards"] as? [String] else {
            // if the user has no 'dreamcards' field yet, return an empty array
            print("User has no dream cards.")
            return []
        }
        
        if cardIDs.isEmpty {
            return []
        }
        
        // fetch each card document from the "DREAMCARDS" collection using the IDs
        var dreamCards: [CardModel] = []
        for cardID in cardIDs {
            let cardRef = fb.db.collection("DREAMCARDS").document(cardID)
            do {
                // decode the document directly into a CardModel object
                let card = try await cardRef.getDocument(as: CardModel.self)
                dreamCards.append(card)
            } catch {
                print("Failed to fetch or decode card with ID \(cardID): \(error)")
            }
        }
        return dreamCards
    }
}
