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
    
    func processDreamsIntoWeeklyLengthCounts(dreams: [DreamModel]) -> ([AvgDreamLengthModel], Double) {
        let calendar = Calendar.current
        let now = Date()
        
        let dreamsByWeek = Dictionary(grouping: dreams) { (dream) -> Date in
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dream.date)
            return calendar.date(from: components) ?? calendar.startOfDay(for: dream.date)
        }
        
        var weeklyAverageLengths = dreamsByWeek.mapValues { dreamsInWeek -> Int in
            let dreamCount = dreamsInWeek.count
            guard dreamCount > 0 else { return 0 }
            
            let totalCharacters = dreamsInWeek.reduce(0) { (currentSum, dream) in
                return currentSum + dream.loggedContent.count
            }
            
            return totalCharacters / dreamCount
        }
        var last3WeeksTotalCharacters: Int = 0
        var last3WeeksTotalDreams: Int = 0
        
        guard let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            let sortedCounts = weeklyAverageLengths.map { AvgDreamLengthModel(date: $0.key, count: $0.value) }.sorted { $0.date < $1.date }
            return (sortedCounts, 0)
        }
        
        for i in 0..<7 {
            guard let weekStartDate = calendar.date(byAdding: .weekOfYear, value: -i, to: startOfCurrentWeek) else {
                continue
            }
            
            let avgLengthForWeek = weeklyAverageLengths[weekStartDate] ?? 0
            
            if weeklyAverageLengths[weekStartDate] == nil {
                weeklyAverageLengths[weekStartDate] = 0
            }
            
            if i < 3 {
                let dreamsInThisWeek = dreamsByWeek[weekStartDate] ?? []
                
                last3WeeksTotalDreams += dreamsInThisWeek.count
                last3WeeksTotalCharacters += dreamsInThisWeek.reduce(0) { $0 + $1.loggedContent.count }
            }
        }
        
        let all7WeeksData = weeklyAverageLengths.map { (weekStartDate, avgCount) -> AvgDreamLengthModel in
            return AvgDreamLengthModel(date: weekStartDate, count: avgCount)
        }
        
        let last3WeeksAverage = (last3WeeksTotalDreams == 0) ? 0.0 : Double(last3WeeksTotalCharacters) / Double(last3WeeksTotalDreams)
        
        let sorted7WeeksData = all7WeeksData.sorted { $0.date < $1.date }
        
        print("Weekly AVERAGE character counts (7 weeks): \(sorted7WeeksData)")
        print("Overall AVERAGE characters in last 3 weeks: \(last3WeeksAverage)")
        
        return (sorted7WeeksData, last3WeeksAverage)
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
}
