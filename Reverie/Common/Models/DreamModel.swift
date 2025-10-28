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
    var finishedDream: String = "None"
    
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

    /// Returns the most recent dreams up to the specified count.
    /// - Parameters:
    ///   - dreams: The full list of DreamModel instances.
    ///   - count: The number of most recent dreams to return (default: 10).
    /// - Returns: An array of the most recent DreamModel objects.
    static func getRecentDreams(from dreams: [DreamModel], count: Int = 10) -> [DreamModel] {
        // Sort dreams by date (most recent first)
        let sortedDreams = dreams.sorted { $0.date > $1.date }
        
        // Return the first 'count' dreams (or fewer if list is smaller)
        return Array(sortedDreams.prefix(count))
    }

    init(userID: String, id: String, title: String, date: Date, loggedContent: String, generatedContent: String, tags: [Tags], image: String, emotion: Emotions, finishedDream: String) {
        self.userID = userID
        self.id = id
        self.title = title
        self.date = date
        self.loggedContent = loggedContent
        self.generatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
        self.finishedDream = finishedDream
    }
}
