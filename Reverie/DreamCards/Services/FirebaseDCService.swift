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

//extension Notification.Name {
//    static let dreamCardsDidUpdate = Notification.Name("dreamCardsDidUpdate")
//}

class FirebaseDCService {
    static let shared = FirebaseDCService()
    let fb = FirebaseLoginService.shared

    func generateImageForDC(for dream: DreamModel) {
        let dreamID = dream.id
        print("dreamID: \(dreamID)")
        if dream.id == "blank" {
            return
        }
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
                guard let sticker = try await ImageGenerationService.shared.generateSticker(prompt: character[0], isSticker: true) else { return }
                print("storing in fb")
                let url = try await FirebaseStorageService.shared.uploadSticker(sticker, forUserID: userID, dreamID: dreamID)
                print("saved in fb")
                print("saving with id \(dreamID)")
                let newCard = await FirebaseDCService.shared.createDC(
                    card: CardModel(
                        userID: userID,
                        id: dreamID,
                        name: character[1],
                        description: character[2],
                        image: url.absoluteString,
                        cardColor: CardModel.DreamColor.allCases.randomElement() ?? .purple
                    )
                )
                await FirebaseLoginService.shared.currUser?.dreamCards.append(newCard!)
                print("finished")
            }
        } catch {
            print("Failed to fetch prompt for dream \(dreamID): \(error)")
            return
        }
    }
    
    func generateImage(for dream: DreamModel) {
        let dreamID = dream.id
        print("dreamID: \(dreamID)")
        if dream.id == "blank" {
            return
        }
        let dreamText = dream.loggedContent
        let userID = dream.userID
        do {
            Task.detached(priority: .utility) {
                print("getting prompt")
                let image = try await StoryBookFoundationModelService.shared.getPrompts(dreamText: dreamText)
                guard image.count == 3 else {
                    print("Invalid character count for dream \(dreamID)")
                    return
                }
                var urls: [String] = []
                for num in 0...2 {
                    print("generating image")
                    guard let image = try await ImageGenerationService.shared.generateSticker(prompt: image[num], isSticker: false) else { return }
                    print("storing in fb")
                    let url = try await FirebaseStorageService.shared.uploadImage(image, forUserID: userID, dreamID: dreamID, index: num)
                    urls.append(url.absoluteString)
                }
                await FirebaseDreamService.shared.storeImages(dream: dream, urls: urls)
                print("finished")
            }
        } catch {
            print("Failed to fetch prompt for dream \(dreamID): \(error)")
            return
        }
    }
    
    func generateDummyImage() {
        Task.detached(priority: .utility) {
            print("dummy image generating")
            guard let image = try await ImageGenerationService.shared.generateSticker(prompt: "dog", isSticker: false) else { return }
            print("finished")
        }
    }
    
    func createDC(card: CardModel) async -> CardModel? {
        do {
            try await fb.db.collection("DREAMCARDS").document(card.id).setData(from: card)
            let userRef = fb.db.collection("USERS").document(card.userID)
            try await userRef.updateData(["dreamcards": FieldValue.arrayUnion([card.id])])
            return try await fb.db.collection("DREAMCARDS").document(card.id).getDocument(as: CardModel.self)
        } catch {
            return nil
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
    
    func fetchDCCards(userID: String) async throws -> [CardModel] {
        print("fetching dc cards")

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
