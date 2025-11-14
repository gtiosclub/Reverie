//
//  AvgDreamLengthService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/14/25.
//

import Foundation
import SwiftUI

class AvgDreamLengthService {
    static let shared = AvgDreamLengthService()
    
    func processDreamsIntoWeeklyLengthCounts(dreams: [DreamModel]) -> ([AvgDreamLengthModel], Int) {
        let calendar = Calendar.current
        let now = Date()
        
        let dreamsByWeek = Dictionary(grouping: dreams) { (dream) -> Date in
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dream.date)
            return calendar.date(from: components) ?? calendar.startOfDay(for: dream.date)
        }
        
        // dictionary -> [Date: Int]
        var weeklyCharacterCounts = dreamsByWeek.mapValues { dreamsInWeek -> Int in
            // iterates over all dreams in that week and sums their loggedContent.count
            return dreamsInWeek.reduce(0) { (currentSum, dream) in
                return currentSum + dream.loggedContent.count
            }
        }
        
        var last3WeeksCharacterCount: Int = 0
        
        guard let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            // Fallback: just return the counts we have
            let sortedCounts = weeklyCharacterCounts.map { AvgDreamLengthModel(date: $0.key, count: $0.value) }.sorted { $0.date < $1.date }
            return (sortedCounts, 0)
        }
        
        for i in 0..<7 {
            guard let weekStartDate = calendar.date(byAdding: .weekOfYear, value: -i, to: startOfCurrentWeek) else {
                continue
            }
            
            // if weeks has no dreams, = 0
            let countForWeek = weeklyCharacterCounts[weekStartDate] ?? 0
            
            if weeklyCharacterCounts[weekStartDate] == nil {
                weeklyCharacterCounts[weekStartDate] = 0
            }
            
            // num of characters in last three weeks
            if i < 3 {
                last3WeeksCharacterCount += countForWeek
            }
        }

        let all7WeeksData = weeklyCharacterCounts.map { (weekStartDate, count) -> AvgDreamLengthModel in
            return AvgDreamLengthModel(date: weekStartDate, count: count)
        }
        
        let sorted7WeeksData = all7WeeksData.sorted { $0.date < $1.date }
        
        print("Weekly character counts (7 weeks): \(sorted7WeeksData)")
        print("Total characters in last 3 weeks: \(last3WeeksCharacterCount)")
        return (sorted7WeeksData, last3WeeksCharacterCount)
    }
    
    // get all time average dreams per week
    func averageCharactersPerWeek(dreams: [AvgDreamLengthModel]) -> Double {
        guard !dreams.isEmpty else { return 0 }
        
        let totalCharacters = dreams.reduce(0) { $0 + $1.count }
        
        return Double(totalCharacters) / Double(dreams.count)
    }
    
    // gets trend information
    func trendTextCharacters(allTimeAvg: Double, ThreeWeekAvg: Double) -> String {
        if allTimeAvg * 1.1 < ThreeWeekAvg {
            return "Over the last 3 weeks, you’ve wrote more in your dreams on average."
        } else if allTimeAvg > ThreeWeekAvg * 1.1 {
            return "Over the last 3 weeks, you’ve wrote less in your dreams than usual."
        } else {
            return "Over the last 3 weeks, you've wrote about the same as usual in your dreams."
        }
    }
    
    func getDreamCountForLastThreeWeeks(dreams: [DreamModel]) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let startOfToday = calendar.startOfDay(for: now)
        guard let threeWeeksAgo = calendar.date(byAdding: .day, value: -21, to: startOfToday) else {
            return 0
        }
        
        let recentDreams = dreams.filter { dream in
            return dream.date >= threeWeeksAgo
        }
        
        return Double(recentDreams.count)
    }
}
