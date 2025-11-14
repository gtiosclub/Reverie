//
//  SimilarityMatrix.swift
//  Reverie
//
//  Created by Shreeya Garg on 11/12/25.
//

import Foundation

func generateDreamsSimilarityMatrix(for dreams: [DreamModel]) -> [[Double]] {
    let count = dreams.count
    var similarityMatrix = Array(repeating: Array(repeating: 0.0, count: count), count: count)

    for i in 0..<count {
        for j in 0..<count {
            if i == j {
                similarityMatrix[i][j] = 1.0
            } else {
                let sim = DreamModel.calculateSimilarity(between: dreams[i], and: dreams[j])
                similarityMatrix[i][j] = sim
            }
        }
    }
    return similarityMatrix
}
