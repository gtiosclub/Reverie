////
////  HealthKitDuringSleep.swift
////  Reverie
////
////  Created by Shreeya Garg on 11/15/25.
////
//
//
//import Foundation
//import HealthKit
//
//final class HealthKitDuringSleep {
//    
//    let healthStore = HKHealthStore()
//    
//    func fetchHeartRateDuringSleep(
//        sleepSegments: [SleepSegment],
//        completion: @escaping ([DataPoint]) -> Void
//    ) {
//        // Find the actual sleep window from segments
//        guard !sleepSegments.isEmpty,
//              let sleepStart = sleepSegments.map({ $0.start }).min(),
//              let sleepEnd = sleepSegments.map({ $0.end }).max(),
//              let hrType = HKObjectType.quantityType(forIdentifier: .heartRate)
//        else {
//            completion([])
//            return
//        }
//        
//        let predicate = HKQuery.predicateForSamples(
//            withStart: sleepStart,
//            end: sleepEnd,
//            options: .strictStartDate
//        )
//        
//        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
//        
//        let query = HKSampleQuery(
//            sampleType: hrType,
//            predicate: predicate,
//            limit: HKObjectQueryNoLimit,
//            sortDescriptors: [sort]
//        ) { _, samples, error in
//            guard let samples = samples as? [HKQuantitySample] else {
//                DispatchQueue.main.async { completion([]) }
//                return
//            }
//            
//            let hrUnit = HKUnit(from: "count/min")
//            let points = samples.map { sample in
//                DataPoint(
//                    date: sample.startDate,
//                    value: sample.quantity.doubleValue(for: hrUnit)
//                )
//            }
//            
//            DispatchQueue.main.async { completion(points) }
//        }
//        
//        healthStore.execute(query)
//    }
//    
//    /// Fetch multiple metrics during sleep time
//    func fetchMetricsDuringSleep(
//        sleepSegments: [SleepSegment],
//        metrics: [HKQuantityTypeIdentifier],
//        completion: @escaping ([HKQuantityTypeIdentifier: [DataPoint]]) -> Void
//    ) {
//        guard !sleepSegments.isEmpty,
//              let sleepStart = sleepSegments.map({ $0.start }).min(),
//              let sleepEnd = sleepSegments.map({ $0.end }).max()
//        else {
//            completion([:])
//            return
//        }
//        
//        var results: [HKQuantityTypeIdentifier: [DataPoint]] = [:]
//        let group = DispatchGroup()
//        
//        for identifier in metrics {
//            guard let qType = HKObjectType.quantityType(forIdentifier: identifier) else {
//                continue
//            }
//            
//            group.enter()
//            
//            let predicate = HKQuery.predicateForSamples(
//                withStart: sleepStart,
//                end: sleepEnd,
//                options: .strictStartDate
//            )
//            
//            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
//            
//            let query = HKSampleQuery(
//                sampleType: qType,
//                predicate: predicate,
//                limit: HKObjectQueryNoLimit,
//                sortDescriptors: [sort]
//            ) { _, samples, _ in
//                defer { group.leave() }
//                
//                guard let samples = samples as? [HKQuantitySample] else { return }
//                
//                let unit = self.unitFor(identifier: identifier)
//                let points = samples.map { sample in
//                    DataPoint(
//                        date: sample.startDate,
//                        value: sample.quantity.doubleValue(for: unit)
//                    )
//                }
//                
//                results[identifier] = points
//            }
//            
//            healthStore.execute(query)
//        }
//        
//        group.notify(queue: .main) {
//            completion(results)
//        }
//    }
//    
//    // Helper to get appropriate unit for each metric
//    private func unitFor(identifier: HKQuantityTypeIdentifier) -> HKUnit {
//        switch identifier {
//        case .heartRate, .restingHeartRate, .respiratoryRate:
//            return HKUnit(from: "count/min")
//        case .heartRateVariabilitySDNN:
//            return HKUnit.secondUnit(with: .milli)
//        case .oxygenSaturation:
//            return HKUnit.percent()
//        case .stepCount:
//            return HKUnit.count()
//        case .distanceWalkingRunning:
//            return HKUnit.meterUnit(with: .kilo)
//        case .activeEnergyBurned:
//            return HKUnit.kilocalorie()
//        default:
//            return HKUnit.count()
//        }
//    }
//}
//
//
