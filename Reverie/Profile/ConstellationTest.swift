//
//  ConstellationTest.swift
//  Reverie
//
//  Created by Isha Jain on 10/13/25.
//

import Foundation

func generateRandomDreamsAndMatrix(count: Int, strongConnections: Int = 3) -> ([DreamModel], [[Double]]) {
    var dreams: [DreamModel] = []

    for i in 0..<count {
        let randomTags = DreamModel.Tags.allCases.shuffled().prefix(Int.random(in: 1...4))
        let allEmotions = DreamModel.Emotions.allCases

        let dream = DreamModel(
            userID: "user\(i)",
            id: UUID().uuidString,
            title: "Dream \(i + 1)",
            date: Date(),
            loggedContent: "Dream \(i + 1)",
            generatedContent: "Generated content for dream \(i + 1)",
            tags: Array(randomTags),
            image: "placeholder",
            emotion: allEmotions.randomElement()!
        )
        dreams.append(dream)
    }

    var similarityMatrix = Array(repeating: Array(repeating: 0.0, count: count), count: count)

    for i in 0..<count {
        similarityMatrix[i][i] = 1.0
    }

    for i in 0..<count {
        let indices = Array(0..<count).filter { $0 != i }.shuffled()
        for j in indices.prefix(strongConnections) {
            let sim = Double.random(in: 0.5...1.0)
            similarityMatrix[i][j] = sim
            similarityMatrix[j][i] = sim
        }
    }

    for i in 0..<count {
        for j in i+1..<count {
            if similarityMatrix[i][j] == 0.0 {
                let sim = Double.random(in: 0...0.3)
                similarityMatrix[i][j] = sim
                similarityMatrix[j][i] = sim
            }
        }
    }

    return (dreams, similarityMatrix)
}
