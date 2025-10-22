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

    init(userID: String, id: String, title: String, date: Date, loggedContent: String, generatedContent: String, tags: [Tags], image: String, emotion: Emotions) {
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

// MARK: - Dream Similarity Extension

extension DreamModel {
    /// Calculates a similarity score between two dreams based on shared tags and emotion.
    /// - Parameters:
    ///   - dream1: The first DreamModel.
    ///   - dream2: The second DreamModel.
    /// - Returns: A Double between 0.0 (no similarity) and 1.0 (identical).
    static func calculateSimilarity(between dream1: DreamModel, and dream2: DreamModel) -> Double {
        // Convert tags into sets for easy comparison
        let tags1 = Set(dream1.tags)
        let tags2 = Set(dream2.tags)
        
        // Shared tags ratio
        let sharedTags = tags1.intersection(tags2)
        let maxTags = max(tags1.count, tags2.count)
        let tagSimilarity = maxTags > 0 ? Double(sharedTags.count) / Double(maxTags) : 0.0
        
        // Emotion similarity (1.0 if same, 0.0 otherwise)
        let emotionSimilarity = dream1.emotion == dream2.emotion ? 1.0 : 0.0
        
        // Weighted total (tags = 70%, emotion = 30%)
        let totalSimilarity = (tagSimilarity * 0.7) + (emotionSimilarity * 0.3)
        
        return totalSimilarity
    }

    /// Provides a text-based label for a given similarity score.
    /// - Parameter score: Similarity value from 0.0 to 1.0.
    /// - Returns: A human-readable label for similarity.
    static func similarityLabel(for score: Double) -> String {
        switch score {
        case 0.8...1.0:
            return "Highly Similar"
        case 0.5..<0.8:
            return "Moderately Similar"
        case 0.2..<0.5:
            return "Slightly Similar"
        default:
            return "Different"
        }
    }
}
