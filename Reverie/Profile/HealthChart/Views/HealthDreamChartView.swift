//
//  HealthChartView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/15/25.
//

import SwiftUI
import Charts

enum HealthMetric: String, CaseIterable, Identifiable {
    case sleep = "Sleep"
    case exercise = "Exercise"
    case calories = "Calories"
    case steps = "Steps"

    var id: String { rawValue }
}

struct HealthDreamChartView: View {
    @State private var dreamData: [DreamFrequencyChartModel] = CleanDreamDataService.shared.processDreamsIntoWeeklyCounts(dreams: ProfileService.shared.dreams).0
    
    @Binding var dreamHealthData: [DailyHealthData]
    
    @State var isHomeView: Bool
    
    @State var selectedMetric: HealthMetric = .sleep
    
    private var sleepData: [SleepDurationChartModel] {
        dreamHealthData.map { SleepDurationChartModel(date: $0.date, hours: $0.sleepDuration) }
    }
    
    private var exerciseData: [ExerciseMinutesChartModel] {
        dreamHealthData.map { ExerciseMinutesChartModel(date: $0.date, minutes: $0.exerciseMinutes) }
    }
    
    private var stepsData: [StepsChartModel] {
        dreamHealthData.map { StepsChartModel(date: $0.date, steps: $0.steps) }
    }
    
    private var caloriesData: [CaloriesBurnedChartModel] {
        dreamHealthData.map { CaloriesBurnedChartModel(date: $0.date, calories: $0.caloriesBurned) }
    }
    
    var body: some View {
        if !isHomeView {
            Picker("Metric", selection: $selectedMetric) {
                ForEach(HealthMetric.allCases) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.indigo)
                        .font(.system(size: 14, weight: .bold))
                        .padding(.trailing, 1)
                    
                    Text("Dreams")
                        .foregroundColor(.indigo)
                        .font(.system(size: 14))
                        .bold()
                    
                    Spacer()
                    
                    if isHomeView {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
                .padding(.top, 6)
                
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 1)
                    .padding(.horizontal, 8)
                    .padding(.top, 6)
                    .padding(.bottom, 4)
            }
            
            HealthChartView(
                dreamData: $dreamData,
                sleepData: .constant(sleepData),
                exerciseData: .constant(exerciseData),
                stepsData: .constant(stepsData),
                caloriesData: .constant(caloriesData),
                selectedMetric: $selectedMetric,
                isHomeView: $isHomeView
            )
        }
        .padding()
        .padding(.bottom, 10)
        .darkGloss()
    }
}

struct HealthChartView: View {
    @Binding var dreamData: [DreamFrequencyChartModel]
    @Binding var sleepData: [SleepDurationChartModel]
    @Binding var exerciseData: [ExerciseMinutesChartModel]
    @Binding var stepsData: [StepsChartModel]
    @Binding var caloriesData: [CaloriesBurnedChartModel]
    
    @State var maxDream: Int = 10
    @State var maxSleep: Int = 10
    @State var maxExercise: Int = 20
    @State var maxSteps: Int = 5000
    @State var maxCalories: Int = 200
    
    @Binding var selectedMetric: HealthMetric
    @Binding var isHomeView: Bool
    
    var maxMetricValue: Int {
        switch selectedMetric {
        case .sleep:
            return maxSleep
        case .exercise:
            return maxExercise
        case .steps:
            return maxSteps
        case .calories:
            return maxCalories
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Chart {
                    ForEach(dreamData) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Dream Count", data.count)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.indigo)
                        .symbol(.circle)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisGridLine()
                        AxisValueLabel()
                    }
                    AxisMarks(position: .leading, values: [50]) { _ in
                        AxisGridLine()
                        AxisValueLabel(centered: false)
                            .foregroundStyle(.clear)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 14)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
                    }
                }
                .chartYScale(domain: 0...maxDream)
                
                Chart {
                    switch selectedMetric {
                    case .sleep:
                        ForEach(sleepData) { sleep in
                            LineMark(
                                x: .value("Date", sleep.date),
                                y: .value("Sleep (h)", sleep.hours),
                                series: .value("Data", "Sleep")
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.purple)
                            .symbol(.square)
                        }
                        
                    case .exercise:
                        ForEach(exerciseData) { exercise in
                            LineMark(
                                x: .value("Date", exercise.date),
                                y: .value("Exercise (min)", exercise.minutes),
                                series: .value("Data", "Exercise")
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.purple)
                            .symbol(.square)
                        }
                        
                    case .steps:
                        ForEach(stepsData) { step in
                            LineMark(
                                x: .value("Date", step.date),
                                y: .value("Steps (k)", Double(step.steps)),
                                series: .value("Data", "Steps")
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.purple)
                            .symbol(.square)
                        }
                        
                    case .calories:
                        ForEach(caloriesData) { cal in
                            LineMark(
                                x: .value("Date", cal.date),
                                y: .value("Calories (k)", cal.calories),
                                series: .value("Data", "Calories")
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(.purple)
                            .symbol(.square)
                        }
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .trailing) {
                        AxisGridLine()
                        AxisValueLabel()
                    }
                    AxisMarks(position: .trailing, values: [50]) { _ in
                        AxisGridLine()
                        AxisValueLabel(centered: false)
                            .foregroundStyle(.clear)
                    }
                }
                .chartYScale(domain: 0...maxMetricValue)
            }
        }
        .padding(.horizontal)
        .frame(height: 260)
        .task {
            maxSleep = Int(ceil((sleepData.map { $0.hours }.max() ?? 9) + 1))
            maxExercise = Int(ceil((exerciseData.map { $0.minutes }.max() ?? 20) + 5))
            maxSteps = Int(ceil((stepsData.map { Double($0.steps) }.max() ?? 5000) + 500))
            maxCalories = Int(ceil((caloriesData.map { $0.calories }.max() ?? 200) + 50))
            maxDream = (dreamData.map { $0.count }.max() ?? 9) + 1
        }
    }
}

#Preview {
    DreamFrequencyChartView(isHomeView: true)
}

