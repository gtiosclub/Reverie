//
//  HealthKitModel.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/15/25.
//

import HealthKit

struct DailyHealthData {
    var date: Date
    var sleepDuration: TimeInterval
    var remSleep: TimeInterval
    var exerciseMinutes: Double
    var caloriesBurned: Double
    var steps: Int
}
