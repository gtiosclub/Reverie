// FirebaseDreamService.swift
// Reverie
//
// Created by Neel Sani on 9/29/25.
//

import Firebase

@MainActor
@Observable
class FirebaseDreamService {
    static let shared = FirebaseDreamService()
    
    let fb = FirebaseUserService()
    
    func getDreams() async throws -> [DreamModel] {
        let dreamKeys = try await fb.getUserInfo()
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
                let dateString = data["date"] as? String,  // adjust if stored as Timestamp
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
            let formatter = ISO8601DateFormatter()
            let date = formatter.date(from: dateString) ?? Date()
            
            // Convert emotion string → enum
            let emotion: DreamModel.Emotions
            switch emotionString.lowercased() {
                case "happiness": emotion = .happiness
                case "sadness": emotion = .sadness
                case "anger": emotion = .anger
                case "fear": emotion = .fear
                case "embarrassment": emotion = .embarrassment
                case "anxiety": emotion = .anxiety
                default:
                    print("⚠️ Unknown emotion: \(emotionString), defaulting to .anxiety")
                    emotion = .anxiety
            }
            
            // Convert tags strings → enum
            let tags: [DreamModel.Tags] = tagsArray.compactMap { tagStr in
                switch tagStr.lowercased() {
                case "mountains": return .mountains
                case "rivers": return .rivers
                case "forests": return .forests
                case "animals": return .animals
                case "school": return .school
                default:
                    print("⚠️ Unknown tag: \(tagStr)")
                    return nil
                }
            }
            
            // Build model
            let dream: DreamModel = .init(
                userId: userId,
                id: id,
                title: "", //this should probably change
                date: date,
                loggedContent: loggedContent,
                generatedContent: generatedContent,
                tags: tags,
                image: image,
                emotion: emotion
            )
            
            dreams.append(dream)
        }
        
        return dreams
    }
}
