//
//  HealthModels.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/15/25.
//

import Foundation

struct SleepDurationChartModel: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
}

struct ExerciseMinutesChartModel: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Double
}

struct StepsChartModel: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Int
}

struct CaloriesBurnedChartModel: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Double
}

struct MetricPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct DreamRelativeFrequencyChartModel: Identifiable {
    let id: UUID
    let date: Date
    let count: Int
}
