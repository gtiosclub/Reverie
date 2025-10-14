// FirebaseDreamService.swift
// Reverie
//
// Created by Neel Sani on 9/29/25.
//

import Firebase
import Foundation
import FirebaseStorage
import SwiftUI

@MainActor
@Observable
class FirebaseDreamService {
    
    static let shared = FirebaseDreamService()
    
    let fb = FirebaseLoginService()
    
    let dcfms = DCFoundationModelService()
    
    let igs = ImageGenerationService()
    
    let fdcs = FirebaseDCService()
    
    func getDreams() async throws -> [DreamModel] {
        guard let user = FirebaseLoginService.shared.currUser else {
            print("No current user found.")
            return []
        }
        let dreamKeys = user.dreams.map { $0.id }
        var dreams: [DreamModel] = []
        
        for dreamKey in dreamKeys {
            let dreamRef = fb.db.collection("DREAMS").document(dreamKey)
            print("Fetching document for key \(dreamKey)…")
            
            let snapshot = try await dreamRef.getDocument()
            guard let data = snapshot.data() else {
                print("⚠️ No data in snapshot for key: \(dreamKey)")
                continue
            }
            
            print("✅ Document data: \(data)")
            
            guard
                let userId = data["userID"] as? String,
                let id = data["id"] as? String,
                let title = data["title"] as? String,
                let dateString = data["date"] as? String,  // adjust if stored as Timestamp
                let title = data["title"] as? String,
                let loggedContent = data["loggedContent"] as? String,
                let generatedContent = data["generatedContent"] as? String,
                let image = data["image"] as? String,
                let emotionString = data["emotion"] as? String,
                let tagsArray = data["tags"] as? [String]
            else {
                print("⚠️ Missing or invalid fields for dream \(dreamKey)")
                continue
            }
            
            // Convert date
            let formatter = DateFormatter()
            let date = formatter.date(from: dateString) ?? Date()
            
            let emotion = DreamModel.Emotions(rawValue: emotionString.lowercased())
            
            let tags: [DreamModel.Tags] = tagsArray.compactMap { DreamModel.Tags(rawValue: $0.lowercased()) }
            
            // Build model
            let dream: DreamModel = .init(
                userID: userId,
                id: id,
                title: title,
                date: date,
                loggedContent: loggedContent,
                generatedContent: generatedContent,
                tags: tags,
                image: image,
                emotion: emotion ?? .happiness
            )
            
            dreams.append(dream)
        }
        
        return dreams
    }
    
    func createDream(dream: DreamModel) async {

          let dateFormatter = DateFormatter()
          dateFormatter.dateStyle = .short
          dateFormatter.locale = Locale(identifier: "en_US_POSIX")

          //create array of tag strings
          var tagArray: [String] = []

          for tag in dream.tags {
              tagArray.append(tag.rawValue)
          }

          print("USER ID: \(dream.userID)")

          do {
              let ref = fb.db.collection("DREAMS").addDocument(data: [
                "date": dateFormatter.string(from: dream.date),
                  "emotion": String(describing: dream.emotion),
                  "generatedContent": dream.generatedContent,
                "title": dream.title,
                   "id": dream.id,
                "image": "",//stickerURL.absoluteString,
                  "loggedContent": dream.loggedContent,
                  "tags": tagArray,
                  "userID": dream.userID
              ])
              let dreamRef = ref.documentID
              dream.id = dreamRef
              print("Added Data with ref: \(dreamRef)")
              
              try await ref.updateData(["id": dreamRef])

              let userRef = fb.db.collection("USERS").document(dream.userID)

              try await userRef.updateData([
                  "dreams": FieldValue.arrayUnion([dreamRef])
                  ])
              

              print("Appended \(dreamRef) to user \(dream.userID)")

              do {
                  let character = try await dcfms.getCharacterPrompt(dreamText: dream.loggedContent)
                  print("Prompt generated: \(character)")

                  if character.count == 3 {
                      let prompt = character[0]
                      let name = character[1]
                      let description = character[2]
                      
                      print("Prompt: \(prompt)")
                      print("Name: \(name)")
                      print("Description: \(description)")
                      
                      guard let sticker = try await igs.generateSticker(prompt: prompt) else {
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
                      
                      await fdcs.createDC(card: CardModel(userID: dream.userID, id: dream.id, name: name, description: description, image: stickerURL.absoluteString, cardColor: .blue))
                  }
              } catch {
                  print("Failed to get character details: \(error)")
              }
          } catch {
              print("Error adding document: \(error)")
          }
        
        
        
        FirebaseLoginService.shared.currUser?.dreams.append(dream)
        
      }
}

