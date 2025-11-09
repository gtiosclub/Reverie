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
    var image: [String?]
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

    // MARK: - Tag Image Helper
    static func getTagImage(tag: Tags) -> String {
        switch tag {
        case .mountains: return "mountain.2.fill"
        case .rivers: return "figure.open.water.swim"
        case .forests: return "tree.fill"
        case .animals: return "pawprint.fill"
        case .school: return "graduationcap.fill"
        }
    }

    // MARK: - Recent Dreams
    /// Returns the most recent dreams up to the specified count.
    /// - Parameters:
    ///   - dreams: The full list of DreamModel instances.
    ///   - count: The number of most recent dreams to return (default: 10).
    /// - Returns: An array of the most recent DreamModel objects.
    static func getRecentDreams(from dreams: [DreamModel], count: Int = 10) -> [DreamModel] {
        let sortedDreams = dreams.sorted { $0.date > $1.date }
        return Array(sortedDreams.prefix(count))
    }

    // MARK: - Dream Similarity
    /// Calculates similarity between two dreams based on shared keywords, emotion, and tags.
    /// - Parameters:
    ///   - dream1: The first dream to compare.
    ///   - dream2: The second dream to compare.
    /// - Returns: A similarity score between 0.0 (no similarity) and 1.0 (identical).
    static func calculateSimilarity(between dream1: DreamModel, and dream2: DreamModel) -> Double {
        // Combine logged and generated content
        let text1 = (dream1.loggedContent + " " + dream1.generatedContent).lowercased()
        let text2 = (dream2.loggedContent + " " + dream2.generatedContent).lowercased()
        
        // Tokenize words and create sets
        let words1 = Set(text1.split { !$0.isLetter }.map(String.init))
        let words2 = Set(text2.split { !$0.isLetter }.map(String.init))
        
        // Compute keyword similarity
        let sharedWords = words1.intersection(words2)
        let allWords = words1.union(words2)
        let keywordScore = allWords.isEmpty ? 0.0 : Double(sharedWords.count) / Double(allWords.count)
        
        // Emotion similarity
        let emotionScore = dream1.emotion == dream2.emotion ? 1.0 : 0.0
        
        // Tag similarity
        let sharedTags = Set(dream1.tags).intersection(Set(dream2.tags))
        let allTags = Set(dream1.tags).union(Set(dream2.tags))
        let tagScore = allTags.isEmpty ? 0.0 : Double(sharedTags.count) / Double(allTags.count)
        
        // Weighted similarity (tuneable weights)
        let similarity = (keywordScore * 0.6) + (emotionScore * 0.25) + (tagScore * 0.15)
        return similarity
    }

    // MARK: - Initializer
    init(
        userID: String,
        id: String,
        title: String,
        date: Date,
        loggedContent: String,
        generatedContent: String,
        tags: [Tags],
        image: [String?],
        emotion: Emotions
    ) {
        self.userID = userID
        self.id = id
        self.title = title  
        self.date = date
        self.loggedContent = loggedContent
        self.generatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
        self.finishedDream = "None"
    }
    
    init(
        userID: String,
        id: String,
        title: String,
        date: Date,
        loggedContent: String,
        generatedContent: String,
        tags: [Tags],
        image: [String?],
        emotion: Emotions,
        finishedDream: String
    ) {
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
