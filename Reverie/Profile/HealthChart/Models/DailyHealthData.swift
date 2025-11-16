//
//  HealthKitModel.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/15/25.
//

import HealthKit

struct DailyHealthData {
    var sleepDuration: TimeInterval
    var remSleep: TimeInterval
    var exerciseMinutes: Double
    var caloriesBurned: Double
    var steps: Double
    var sleepScore: Int?
}

extension HealthKitChartService {
    func fetchToday() async throws -> DailyHealthData {
        async let sleepData = fetchSleepSessions()
        async let exercise = fetchQuantityToday(exerciseMinutesType)
        async let calories = fetchQuantityToday(caloriesType)
        async let steps = fetchQuantityToday(stepsType)
        
        let s = try await sleepData
        
        return DailyHealthData(
            sleepDuration: s.total,
            remSleep: s.rem,
            exerciseMinutes: try await exercise,
            caloriesBurned: try await calories,
            steps: try await steps,
            sleepScore: s.score
        )
    }
}
