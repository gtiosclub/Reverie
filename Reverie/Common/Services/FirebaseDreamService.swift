// FirebaseDreamService.swift
// Reverie
//
// Created by Neel Sani on 9/29/25.
//

import Firebase
import Foundation

@MainActor
@Observable
class FirebaseDreamService {
    static let shared = FirebaseDreamService()
    
    let fb = FirebaseLoginService()
//    
//    func getDreams() async throws -> [DreamModel] {
//        guard let dreamKeys = try await fb.currUser?.dreams else { return [] }
//        
//        var dreams: [DreamModel] = []
//        
//        for dreamKey in dreamKeys {
//            let dreamRef = fb.db.collection("DREAMS").document(dreamKey)
//            print("Fetching document for key \(dreamKey)…")
//            
//            let snapshot = try await dreamRef.getDocument()
//            guard let data = snapshot.data() else {
//                print("⚠️ No data in snapshot for key: \(dreamKey)")
//                continue
//            }
//            
//            print("✅ Document data: \(data)")
//            
//            guard
//                let userId = data["userID"] as? String,
//                let id = data["id"] as? String,
//                let title = data["title"] as? String,
//                let dateString = data["date"] as? String,  // adjust if stored as Timestamp
//                let loggedContent = data["loggedContent"] as? String,
//                let generatedContent = data["generatedContent"] as? String,
//                let image = data["image"] as? String,
//                let emotionString = data["emotion"] as? String,
//                let tagsArray = data["tags"] as? [String]
//            else {
//                print("⚠️ Missing or invalid fields for dream \(dreamKey)")
//                continue
//            }
//            
//            // Convert date
//            let formatter = DateFormatter()
//            formatter.locale = Locale(identifier: "en_US_POSIX")
//            formatter.dateFormat = "M/d/yy" // matches .short in many locales; adjust to your stored format if needed
//            let date = formatter.date(from: dateString) ?? Date()
//            
//
//            let emotion = DreamModel.Emotions(rawValue: emotionString.lowercased())
//            
//
//            let tags: [DreamModel.Tags] = tagsArray.compactMap { DreamModel.Tags(rawValue: $0.lowercased()) }
//            
//            // Build model
//            let dream: DreamModel = .init(
//                userID: userId,
//                id: id,
//                title: title,
//                date: date,
//                loggedContent: loggedContent,
//                generatedContent: generatedContent,
//                tags: tags,
//                image: image,
//                emotion: emotion ?? .happiness
//            )
//            
//            dreams.append(dream)
//        }
//        
//        return dreams
//    }
//    
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
              let ref = try await fb.db.collection("DREAMS").addDocument(
                data: [
                 "date": dateFormatter.string(from: dream.date),
                 "emotion": dream.emotion.rawValue,
                 "generatedContent": dream.generatedContent,
                 "title": dream.title,
                 "id": dream.id,
                 "image": dream.image,
                 "loggedContent": dream.loggedContent,
                 "tags": tagArray,
                 "userID": dream.userID
              ])
              let dreamRef = ref.documentID
              print("Added Data with ref: \(dreamRef)")

              let userRef = try await fb.db.collection("USERS").document(dream.userID)

              try await userRef.updateData([
                  "dreams": FieldValue.arrayUnion([dreamRef])
                  ])

              print("Appended \(dreamRef) to user \(dream.userID)")

          } catch {
              print("Error adding document: \(error)")
          }
      }
}

