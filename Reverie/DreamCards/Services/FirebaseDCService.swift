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

class FirebaseDCService {
    static let shared = FirebaseDCService()
    let fb = FirebaseLoginService()

    func generateImage(for dream: DreamModel, isSticker: Bool) {
        let dreamID = dream.id
        let dreamText = dream.loggedContent
        let userID = dream.userID
        do {
            Task.detached(priority: .utility) {
                print("getting prompt")
                let character = try await DCFoundationModelService.shared.getCharacterPrompt(dreamText: dreamText)
                guard character.count == 3 else {
                    print("Invalid character count for dream \(dreamID)")
                    return
                }
                print("generating image")
                guard let sticker = try await ImageGenerationService.shared.generateSticker(prompt: character[0], isSticker: isSticker) else { return }
                print("storing in fb")
                let url = try await FirebaseStorageService.shared.uploadSticker(sticker, forUserID: userID, dreamID: dreamID)
                if isSticker {
                    await FirebaseDCService.shared.createDC(
                        card: CardModel(
                            userID: userID,
                            id: dreamID,
                            name: character[1],
                            description: character[2],
                            image: url.absoluteString,
                            cardColor: .purple
                        )
                    )
                }
                print("finished")
            }
        } catch {
            print("Failed to fetch prompt for dream \(dreamID): \(error)")
            return
        }
    }
    
    func createDC(card: CardModel) async {
        do {
            try fb.db.collection("DREAMCARDS").document(card.id).setData(from: card)
            let userRef = fb.db.collection("USERS").document(card.userID)
            try await userRef.updateData(["dreamcards": FieldValue.arrayUnion([card.id])])
        } catch {
            print("Firebase write error: \(error)")
        }
    }

    func fetchDCCards() async throws -> [CardModel] {
        print("fetching dc cards")
        guard let userID = fb.currUser?.userID else { return [] }

        let userDocRef = fb.db.collection("USERS").document(userID)
        let userDocument = try await userDocRef.getDocument()

        guard let data = userDocument.data(),
              let cardIDs = data["dreamcards"] as? [String] else { return [] }

        if cardIDs.isEmpty { return [] }

        var dreamCards: [CardModel] = []
        for cardID in cardIDs {
            let cardRef = fb.db.collection("DREAMCARDS").document(cardID)
            do {
                let card = try await cardRef.getDocument(as: CardModel.self)
                dreamCards.append(card)
            } catch {
                print("Failed to fetch or decode card with ID \(cardID): \(error)")
            }
        }
        return dreamCards
    }
}
