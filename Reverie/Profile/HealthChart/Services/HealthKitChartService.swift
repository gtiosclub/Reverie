//
//  HealthKitService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/15/25.
//

import HealthKit

#if !canImport(HealthKit) || (os(iOS) && swift(>=5.9))
// Xcode 15/iOS 17+ provides this, but define it if missing
let HKMetadataKeySleepScore = "HKMetadataKeySleepScore"
#endif

class HealthKitChartService {
    static let shared = HealthKitChartService()
    let healthStore = HKHealthStore()
    
    let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    let remSleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    let exerciseMinutesType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
    let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
    
    func requestAuthorization() async throws {
        let toRead: Set<HKObjectType> = [
            sleepType,
            exerciseMinutesType,
            caloriesType,
            stepsType
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: toRead)
    }
    
    func fetchLast7WeeksAveraged() async throws -> [DailyHealthData] {
        let healthStore = HKHealthStore()
        let calendar = Calendar.current
        
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -7, to: endDate) else {
            throw NSError(domain: "", code: -1)
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            
            let dispatchGroup = DispatchGroup()
            
            // Raw daily buckets
            var sleepDurations: [Date: Double] = [:]
            var remDurations:   [Date: Double] = [:]
            var steps:          [Date: Int]    = [:]
            var calories:       [Date: Double] = [:]
            var exercise:       [Date: Double] = [:]
            
            func bucketToDay(_ date: Date) -> Date {
                calendar.startOfDay(for: date)
            }
            
            func bucketToWeek(_ date: Date) -> Date {
                calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            }
            
            func fetch<T: HKSampleType>(
                type: T,
                handler: @escaping ([HKSample]) -> Void
            ) {
                dispatchGroup.enter()
                let query = HKSampleQuery(
                    sampleType: type,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, samples, _ in
                    if let samples = samples { handler(samples) }
                    dispatchGroup.leave()
                }
                healthStore.execute(query)
            }
            
            // ----------------------------
            // FETCH: Sleep
            // ----------------------------
            if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
                fetch(type: sleepType) { samples in
                    for s in samples {
                        guard let cat = s as? HKCategorySample else { continue }
                        
                        let day = bucketToDay(cat.startDate)
                        let duration = cat.endDate.timeIntervalSince(cat.startDate)
                        
                        if cat.value == HKCategoryValueSleepAnalysis.asleep.rawValue ||
                            cat.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                            sleepDurations[day, default: 0] += duration
                        }
                        
                        if #available(iOS 16.0, *),
                           cat.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                            remDurations[day, default: 0] += duration
                        }
                    }
                }
            }
            
            // ----------------------------
            // FETCH: Steps
            // ----------------------------
            if let type = HKObjectType.quantityType(forIdentifier: .stepCount) {
                fetch(type: type) { samples in
                    for s in samples {
                        guard let q = s as? HKQuantitySample else { continue }
                        let day = bucketToDay(q.startDate)
                        steps[day, default: 0] += Int(q.quantity.doubleValue(for: .count()))
                    }
                }
            }
            
            // ----------------------------
            // FETCH: Calories
            // ----------------------------
            if let type = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
                fetch(type: type) { samples in
                    for s in samples {
                        guard let q = s as? HKQuantitySample else { continue }
                        let day = bucketToDay(q.startDate)
                        calories[day, default: 0] += q.quantity.doubleValue(for: .kilocalorie())
                    }
                }
            }
            
            // ----------------------------
            // FETCH: Exercise Minutes
            // ----------------------------
            if let type = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) {
                fetch(type: type) { samples in
                    for s in samples {
                        guard let q = s as? HKQuantitySample else { continue }
                        let day = bucketToDay(q.startDate)
                        exercise[day, default: 0] += q.quantity.doubleValue(for: .minute())
                    }
                }
            }
            
            // -------------------------------------------------------
            // FINISH → Convert daily → weekly → averaged weekly model
            // -------------------------------------------------------
            dispatchGroup.notify(queue: .main) {
                
                var weeklyBuckets: [Date: [(Double,Double,Double,Double,Int)]] = [:]
                
                // Build 49 days of points → bucket into weeks
                let days = (0..<49).compactMap { offset -> Date? in
                    calendar.date(byAdding: .day, value: -offset, to: endDate)
                }
                
                for day in days {
                    let startOfDay = bucketToDay(day)
                    let week = bucketToWeek(startOfDay)
                    
                    let sd = sleepDurations[startOfDay] ?? 0
                    let rd = remDurations[startOfDay]   ?? 0
                    let ex = exercise[startOfDay]       ?? 0
                    let cal = calories[startOfDay]      ?? 0
                    let st = steps[startOfDay]          ?? 0
                    
                    weeklyBuckets[week, default: []].append((sd, rd, ex, cal, st))
                }
                
                // Turn weekly bucket → averaged data
                let result: [DailyHealthData] = weeklyBuckets
                    .sorted { $0.key < $1.key }
                    .map { (weekStart, entries) in
                        
                        let count = Double(entries.count)
                        let sum = entries.reduce((0.0,0.0,0.0,0.0,0)) {
                            ($0.0 + $1.0, $0.1 + $1.1, $0.2 + $1.2, $0.3 + $1.3, $0.4 + $1.4)
                        }
                        
                        return DailyHealthData(
                            date: weekStart,
                            sleepDuration: sum.0 / count,
                            remSleep: sum.1 / count,
                            exerciseMinutes: sum.2 / count,
                            caloriesBurned: sum.3 / count,
                            steps: Int(Double(sum.4) / count)
                        )
                    }
                
                continuation.resume(returning: result)
            }
        }
    }
    
    func mapHealthDataToChartModels(_ healthData: [DailyHealthData]) -> (
        sleepData: [SleepDurationChartModel],
        exerciseData: [ExerciseMinutesChartModel],
        stepsData: [StepsChartModel],
        caloriesData: [CaloriesBurnedChartModel]
    ) {
        let sleepData = healthData.map { SleepDurationChartModel(date: $0.date, hours: $0.sleepDuration) }
        let exerciseData = healthData.map { ExerciseMinutesChartModel(date: $0.date, minutes: $0.exerciseMinutes) }
        let stepsData = healthData.map { StepsChartModel(date: $0.date, steps: $0.steps) }
        let caloriesData = healthData.map { CaloriesBurnedChartModel(date: $0.date, calories: $0.caloriesBurned) }

        return (sleepData, exerciseData, stepsData, caloriesData)
    }

    private func unit(for type: HKQuantityType) -> HKUnit {
        switch type {
        case HKQuantityType.quantityType(forIdentifier: .stepCount):
            return .count()
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
            return .kilocalorie()
        case HKQuantityType.quantityType(forIdentifier: .appleExerciseTime):
            return .minute()
        default:
            return .count()
        }
    }
    
    func fetchSleepSessions() async throws -> (total: TimeInterval, rem: TimeInterval, score: Int?) {
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date()
        )

        return try await withCheckedThrowingContinuation { cont in
            let query = HKSampleQuery(sampleType: sleepType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: nil) { _, results, err in
                
                if let err { cont.resume(throwing: err); return }
                
                let samples = results as? [HKCategorySample] ?? []
                
                var total: TimeInterval = 0
                var rem: TimeInterval = 0
                var score: Int? = nil
                
                for sample in samples {
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    let stage = HKCategoryValueSleepAnalysis(rawValue: sample.value)

                    switch stage {
                    case .asleepCore, .asleepUnspecified, .asleepDeep:
                        total += duration

                    case .asleepREM:
                        total += duration
                        rem += duration

                    case .asleep:
                        // iOS 17+ includes sleep score
                        if #available(iOS 17.0, *) {
                            score = sample.metadata?[HKMetadataKeySleepScore] as? Int
                        }
                        total += duration
                        
                    default:
                        break
                    }
                }
                
                cont.resume(returning: (total, rem, score))
            }
            
            healthStore.execute(query)
        }
    }
}

