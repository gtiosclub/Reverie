//
//  CleanDreamDataService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/13/25.
//

import Foundation
import SwiftUI

class CleanDreamDataService {
    static let shared = CleanDreamDataService()
    
    func processDreamsIntoWeeklyCounts(dreams: [DreamModel]) -> (all7Weeks: [DreamFrequencyChartModel], last3Weeks: Int) {
        let calendar = Calendar.current
        let now = Date()
        
        let dreamsByWeek = Dictionary(grouping: dreams) { (dream) -> Date in
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dream.date)
            return calendar.date(from: components) ?? calendar.startOfDay(for: dream.date)
        }
        
        // dictionary -> [Date: Int]
        var weeklyCounts = dreamsByWeek.mapValues { $0.count }
        
        var last3WeeksCounts: Int = 0
        
        guard let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {

            let sortedCounts = weeklyCounts.map { DreamFrequencyChartModel(date: $0.key, count: $0.value) }.sorted { $0.date < $1.date }

            return (all7Weeks: sortedCounts, last3Weeks: 0)
        }
        
        for i in 0..<7 {
            guard let weekStartDate = calendar.date(byAdding: .weekOfYear, value: -i, to: startOfCurrentWeek) else {
                continue
            }
            
            let countForWeek = weeklyCounts[weekStartDate] ?? 0
            
            // if weeks has no dreams, = 0
            if weeklyCounts[weekStartDate] == nil {
                weeklyCounts[weekStartDate] = 0
            }
            
            // num of dreams in last three weeks
            if i < 3 {
                last3WeeksCounts += countForWeek
            }
        }
        
        // map to struct
        let all7WeeksData = weeklyCounts.map { (weekStartDate, count) -> DreamFrequencyChartModel in
            return DreamFrequencyChartModel(date: weekStartDate, count: count)
        }
        
        // print sorted
        print(all7WeeksData)
        print(last3WeeksCounts)
        return (
            all7Weeks: all7WeeksData.sorted { $0.date < $1.date },
            last3Weeks: last3WeeksCounts
        )
    }
        
    // get all time average dreams per week
    func averageDreamsPerWeek(dreams: [DreamFrequencyChartModel]) -> Double {
        guard !dreams.isEmpty else { return 0 }
        
        let totalDreams = dreams.reduce(0) { $0 + $1.count }
        
        return Double(totalDreams) / Double(dreams.count)
    }
    
    // gets trend information
    func trendText(allTimeAvg: Double, ThreeWeekAvg: Double) -> String {
        if allTimeAvg * 1.1 < ThreeWeekAvg {
            return "Over the last 3 weeks, you’ve dreamt more on average."
        } else if allTimeAvg > ThreeWeekAvg * 1.1 {
            return "Over the last 3 weeks, you’ve dreamt less than usual."
        } else {
            return "Your dream frequency has been about the same as usual."
        }
    }
}
