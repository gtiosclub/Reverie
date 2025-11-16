//
//  HealthChartView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/15/25.
//

import SwiftUI
import Charts

struct HealthDreamChartView: View {
    @State private var dreamData: [DreamFrequencyChartModel] = CleanDreamDataService.shared.processDreamsIntoWeeklyCounts(dreams: ProfileService.shared.dreams).0
    
    @Binding var dreamHealthData: [DailyHealthData]
    
    @State var isHomeView: Bool
    
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
                caloriesData: .constant(caloriesData)
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

    var body: some View {
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

//            ForEach(exerciseData) { exercise in
//                LineMark(
//                    x: .value("Date", exercise.date),
//                    y: .value("Exercise (min)", exercise.minutes),
//                    series: .value("Data", "Exercise")
//                )
//                .interpolationMethod(.catmullRom)
//                .foregroundStyle(.purple)
//                .symbol(.square)
//            }

//            ForEach(stepsData) { step in
//                LineMark(
//                    x: .value("Date", step.date),
//                    y: .value("Steps (k)", Double(step.steps)),
//                    series: .value("Data", "Steps")
//                )
//                .interpolationMethod(.catmullRom)
//                .foregroundStyle(.purple)
//                .symbol(.square)
//            }
//
//            ForEach(caloriesData) { cal in
//                LineMark(
//                    x: .value("Date", cal.date),
//                    y: .value("Calories (k)", cal.calories),
//                    series: .value("Data", "Calories")
//                )
//                .interpolationMethod(.catmullRom)
//                .foregroundStyle(.purple)
//                .symbol(.square)
//            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisValueLabel()
            }
            AxisMarks(position: .trailing) {
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 14)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
            }
        }
        .frame(height: 260)
        .padding(.horizontal)
    }
}

#Preview {
    DreamFrequencyChartView(isHomeView: true)
}
