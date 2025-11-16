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
    let sleepScoreType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    func requestAuthorization() async throws {
        let toRead: Set<HKObjectType> = [
            sleepType,
            exerciseMinutesType,
            caloriesType,
            stepsType
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: toRead)
    }
    
    func fetchQuantityToday(_ type: HKQuantityType) async throws -> Double {
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        
        return try await withCheckedThrowingContinuation { cont in
            let query = HKStatisticsQuery(quantityType: type,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, stats, err in
                if let err { cont.resume(throwing: err); return }
                let value = stats?.sumQuantity()?.doubleValue(for: self.unit(for: type)) ?? 0
                cont.resume(returning: value)
            }
            healthStore.execute(query)
        }
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

