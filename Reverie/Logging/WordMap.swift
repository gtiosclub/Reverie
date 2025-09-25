//
//  WordMap.swift
//  Reverie
//
//  Created by Arav Chadha on 9/25/25.
//

import Foundation

struct WordMap {
    
    func getKeywordCount(keywords: [String]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for keyword in keywords {
            counts[keyword, default: 0] += 1
        }
        return counts
    }
}
