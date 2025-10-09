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
    
    // !!when using createDream, you can use any id value for the dream you pass in, it will update with the accurate dream id once the dream is initialized in firebase!!
  
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
              dream.id = dreamRef
              print("Added Data with ref: \(dreamRef)")
              
              try await ref.updateData(["id": dreamRef])

              let userRef = try await fb.db.collection("USERS").document(dream.userID)

              try await userRef.updateData([
                  "dreams": FieldValue.arrayUnion([dreamRef])
                  ])
              

              print("Appended \(dreamRef) to user \(dream.userID)")

          } catch {
              print("Error adding document: \(error)")
          }
        
        
        
        FirebaseLoginService.shared.currUser?.dreams.append(dream)
        
      }
}

