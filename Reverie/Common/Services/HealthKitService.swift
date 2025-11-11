//
//  HealthKitService.swift
//  Reverie
//
//  Created by Anoushka Gudla on 10/28/25.
//

import HealthKit

final class HealthKitService {
    private let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, _ in
            completion(success)
        }
    }
    
    func getSleepTimes(completion: @escaping (SleepTime?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: [])
        
        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: 1,
                                  sortDescriptors: [sortDescriptor]) { (_, results, _) in
            guard let sample = results?.first as? HKCategorySample else {
                completion(nil)
                return
            }
            
            let sleepTime = SleepTime(bedtime: sample.startDate, wakeUpTime: sample.endDate)
            completion(sleepTime)
        }
        
        healthStore.execute(query)
    }
}

