//
//  DreamModel.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/4/25.
//

import Foundation

class DreamModel {
    var id: String
    var userId: String
    var date: Date
    var loggedContent: String
    var generatedContent: String
    var tags: [Tags]
    var image: String
    var emotion: Emotions
    
    enum Tags {
        case mountains, rivers, forests, animals, school
    }
    
    enum Emotions {
        case happiness, sadness, anger, fear, embarrassment, anxiety
    }
    
    init(userId: String,
         id: String,
         date: Date,
         loggedContent: String,
         generatedContent: String,
         tags: [Tags],
         image: String,
         emotion: Emotions) {
        self.userId = userId
        self.id = id
        self.date = date
        self.loggedContent = loggedContent
        self.generatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
    }
}

// MARK: - Helper function
func getRecentDreams(dreams: [String], count: Int = 10) -> [String] {
    // Make sure we don't try to return more dreams than exist
    let numberToReturn = min(count, dreams.count)
    
    // Return the last `numberToReturn` dreams
    return Array(dreams.suffix(numberToReturn))
}

// MARK: - Example test (wrap in function so it compiles)
func testRecentDreams() {
    let dreams = [
        "Flying", "Falling", "Ocean", "Forest", "Stars",
        "Running", "Maze", "Clouds", "Fire", "River",
        "Mountains", "Space"
    ]
    
    print(getRecentDreams(dreams: dreams))
    // Returns last 10 dreams
    
    print(getRecentDreams(dreams: dreams, count: 3))
    // Returns ["River", "Mountains", "Space"]
}
