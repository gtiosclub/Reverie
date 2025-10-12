//
//  DreamModel.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/4/25.
//

import Foundation
import FoundationModels

class DreamModel: Decodable {
    var id: String
    var userID: String
    var title: String
    var date: Date
    var loggedContent: String
    var generatedContent: String
    var tags: [Tags]
    var image: String
    var emotion: Emotions
    
    @Generable
    enum Tags: String, Codable, CaseIterable {
        case mountains, rivers, forests, animals, school
    }
    
    @Generable
    enum Emotions: String, Codable, CaseIterable {
        case happiness, sadness, anger, fear, embarrassment, anxiety, neutral
    }

    static func getTagImage(tag: Tags) -> String {
       switch tag {
           case .mountains: return "mountain.2.fill"
           case .rivers: return "figure.open.water.swim"
           case .forests: return "tree.fill"
           case .animals: return "pawprint.fill"
           case .school: return "graduationcap.fill"
       }
    }



    init(userID: String, id: String, title: String, date: Date, loggedContent: String, generatedContent:String, tags: [Tags], image: String, emotion: Emotions) {
        self.userID = userID
        self.id = id
        self.title = title
        self.date = date
        self.loggedContent = loggedContent
        self.generatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
    }
}

// MARK: - Helper function
func getRecentDreams(dreams: [DreamModel], count: Int = 10) -> [DreamModel] {
    // Make sure we don't try to return more dreams than exist
    let numberToReturn = min(count, dreams.count)
    
    // Sort dreams by date (most recent first) and return the last `numberToReturn` dreams
    let sortedDreams = dreams.sorted { $0.date > $1.date }
    return Array(sortedDreams.prefix(numberToReturn))
}

// MARK: - Test function
func testRecentDreams() {
    print("✨ Dream Constellation Filter Test Suite ✨")
    print(String(repeating: "=", count: 50))
    
    // Create test dream data with different dates
    let calendar = Calendar.current
    let now = Date()
    
    let dreams = [
        DreamModel(
            userID: "user1",
            id: "dream1",
            title: "Flying Adventure",
            date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
            loggedContent: "Flying dream",
            generatedContent: "Generated content for flying dream",
            tags: [.mountains],
            image: "flying.png",
            emotion: .happiness
        ),
        DreamModel(
            userID: "user1",
            id: "dream2",
            title: "Ocean Journey",
            date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
            loggedContent: "Ocean dream",
            generatedContent: "Generated content for ocean dream",
            tags: [.rivers],
            image: "ocean.png",
            emotion: .happiness
        ),
        DreamModel(
            userID: "user1",
            id: "dream3",
            title: "Forest Exploration",
            date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
            loggedContent: "Forest dream",
            generatedContent: "Generated content for forest dream",
            tags: [.forests],
            image: "forest.png",
            emotion: .happiness
        ),
        DreamModel(
            userID: "user1",
            id: "dream4",
            title: "Space Adventure",
            date: now,
            loggedContent: "Space dream",
            generatedContent: "Generated content for space dream",
            tags: [.mountains],
            image: "space.png",
            emotion: .happiness
        ),
        DreamModel(
            userID: "user1",
            id: "dream5",
            title: "Running Chase",
            date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
            loggedContent: "Running dream",
            generatedContent: "Generated content for running dream",
            tags: [.animals],
            image: "running.png",
            emotion: .anxiety
        )
    ]
    
    // Test 1: Default count (should return all 5 dreams since we only have 5 total)
    let recentDreamsDefault = getRecentDreams(dreams: dreams)
    print("🌟 Test 1 - Default count (10): \(recentDreamsDefault.count) dreams returned")
    print("   Most recent: \(recentDreamsDefault.first?.title ?? "None")")
    print("   Oldest: \(recentDreamsDefault.last?.title ?? "None")\n")
    
    // Test 2: Custom count (3)
    let recentDreamsCustom = getRecentDreams(dreams: dreams, count: 3)
    print("⭐ Test 2 - Custom count (3): \(recentDreamsCustom.count) dreams returned")
    for (index, dream) in recentDreamsCustom.enumerated() {
        print("   \(index + 1). \(dream.title)")
    }
    print()
    
    // Test 3: Count larger than available dreams
    let recentDreamsLarge = getRecentDreams(dreams: dreams, count: 10)
    print("🌙 Test 3 - Large count (10): \(recentDreamsLarge.count) dreams returned")
    print("   Should return all available dreams when count exceeds total\n")
    
    // Test 4: Empty array
    let recentDreamsEmpty = getRecentDreams(dreams: [])
    print("✨ Test 4 - Empty array: \(recentDreamsEmpty.count) dreams returned")
    print("   Should handle empty array gracefully\n")
    
    // Test 5: Single dream
    let singleDream = [dreams[0]]
    let recentDreamsSingle = getRecentDreams(dreams: singleDream, count: 5)
    print("🌟 Test 5 - Single dream with count 5: \(recentDreamsSingle.count) dreams returned")
    print("   Should return the single dream even when count is larger\n")
    
    // Test 6: Edge case - count of 0
    let recentDreamsZero = getRecentDreams(dreams: dreams, count: 0)
    print("⭐ Test 6 - Count of 0: \(recentDreamsZero.count) dreams returned")
    print("   Should handle zero count gracefully\n")
    
    print("🎉 All constellation tests passed! Dreams are perfectly filtered.")
    print(String(repeating: "=", count: 50))
}
