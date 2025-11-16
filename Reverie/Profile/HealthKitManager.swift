//
//  HealthKitManager.swift
//  Reverie
//
//  Created by Abhiram Raju on 11/13/25.
//

import Foundation
import HealthKit

final class HealthKitManager {
    let healthStore = HKHealthStore()

    // MARK: Authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Health data not available."]))
            return
        }

        var readTypes = Set<HKObjectType>()

        if let t = HKQuantityType.quantityType(forIdentifier: .heartRate) { readTypes.insert(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) { readTypes.insert(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .stepCount) { readTypes.insert(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) { readTypes.insert(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) { readTypes.insert(t) }

        if let t = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) { readTypes.insert(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) { readTypes.insert(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) { readTypes.insert(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { readTypes.insert(t) }

        healthStore.requestAuthorization(toShare: [], read: readTypes, completion: completion)
    }

    // MARK: Most-recent quantity
    func fetchMostRecentQuantity(for id: HKQuantityTypeIdentifier,
                                 completion: @escaping (HKQuantitySample?) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else {
            completion(nil); return
        }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            DispatchQueue.main.async { completion(samples?.first as? HKQuantitySample) }
        }
        healthStore.execute(q)
    }

    // MARK: Sleep core

    private func stageName(for code: Int, modern: Bool) -> String {
        if modern {
            // iOS16+: 0=inBed, 1=asleepUnspecified, 2=awake, 3=core, 4=deep, 5=rem
            switch code {
            case 0: return "In Bed"
            case 2: return "Awake"
            case 3: return "Core"
            case 4: return "Deep"
            case 5: return "REM"
            default: return "Asleep"
            }
        } else {
            // iOS15-: 0=inBed, 1=asleep, 2=awake
            switch code {
            case 0: return "In Bed"
            case 2: return "Awake"
            default: return "Asleep"
            }
        }
    }

    struct SleepSegment {
        let start: Date
        let end: Date
        let hours: Double
        let stage: String
        let rawValue: Int
        let sourceBundleID: String
    }

    func fetchSleepSegments(start: Date,
                            end: Date,
                            onlyAppleHealthSource: Bool = true,
                            completion: @escaping ([SleepSegment]) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([]); return
        }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let q = HKSampleQuery(sampleType: sleepType,
                              predicate: predicate,
                              limit: HKObjectQueryNoLimit,
                              sortDescriptors: [sort]) { [weak self] _, results, _ in
            guard let self else { DispatchQueue.main.async { completion([]) }; return }

            let modern = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 16
            let samples = (results as? [HKCategorySample]) ?? []
            let filtered = onlyAppleHealthSource
                ? samples.filter { $0.sourceRevision.source.bundleIdentifier.hasPrefix("com.apple.health") }
                : samples

            let segs = filtered.map { s in
                SleepSegment(start: s.startDate,
                             end: s.endDate,
                             hours: s.endDate.timeIntervalSince(s.startDate) / 3600.0,
                             stage: self.stageName(for: s.value, modern: modern),
                             rawValue: s.value,
                             sourceBundleID: s.sourceRevision.source.bundleIdentifier)
            }
            DispatchQueue.main.async { completion(segs) }
        }
        healthStore.execute(q)
    }

    struct SleepBreakdown {
        let remHours: Double
        let deepHours: Double
        let coreHours: Double
        let asleepHours: Double
        let inBedHours: Double
        let awakeHours: Double
        let awakeningsCount: Int
    }

    func fetchPreviousNightSleepBreakdown(onlyAppleHealthSource: Bool = true,
                                          completion: @escaping (SleepBreakdown?) -> Void) {
        let cal = Calendar.current
        let now = Date()
        guard
            let start = cal.date(bySettingHour: 18, minute: 0, second: 0,
                                 of: now.addingTimeInterval(-86400)),
            let end   = cal.date(bySettingHour: 10, minute: 0, second: 0, of: now)
        else { completion(nil); return }

        fetchSleepSegments(start: start, end: end,
                           onlyAppleHealthSource: onlyAppleHealthSource) { segs in
            guard !segs.isEmpty else { completion(nil); return }
            let modern = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 16

            var rem = 0.0, deep = 0.0, core = 0.0
            var asleep = 0.0, inBed = 0.0, awake = 0.0
            var awakens = 0

            for s in segs {
                switch s.stage {
                case "REM":  rem += s.hours; asleep += s.hours
                case "Deep": deep += s.hours; asleep += s.hours
                case "Core": core += s.hours; asleep += s.hours
                case "Asleep":
                    asleep += s.hours
                    if !modern { core += s.hours }
                case "Awake":
                    awake += s.hours
                    awakens += 1
                case "In Bed":
                    inBed += s.hours
                default: break
                }
            }

            completion(SleepBreakdown(remHours: rem,
                                      deepHours: deep,
                                      coreHours: core,
                                      asleepHours: asleep,
                                      inBedHours: inBed,
                                      awakeHours: awake,
                                      awakeningsCount: awakens))
        }
    }
}

// MARK: - Time series

extension HealthKitManager {
    struct DataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }

    func fetchDailyQuantitySeries(identifier: HKQuantityTypeIdentifier,
                                  unit: HKUnit,
                                  daysBack: Int = 14,
                                  options: HKStatisticsOptions = .cumulativeSum,
                                  completion: @escaping ([DataPoint]) -> Void) {
        guard let qType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion([]); return
        }

        let cal = Calendar.current
        let end = cal.startOfDay(for: Date())
        guard let start = cal.date(byAdding: .day, value: -daysBack, to: end) else {
            completion([]); return
        }

        var interval = DateComponents()
        interval.day = 1
        let anchor = cal.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start,
                                                    end: end.addingTimeInterval(24 * 3600),
                                                    options: [])

        let query = HKStatisticsCollectionQuery(quantityType: qType,
                                                quantitySamplePredicate: predicate,
                                                options: options,
                                                anchorDate: anchor,
                                                intervalComponents: interval)

        query.initialResultsHandler = { _, results, _ in
            var out: [DataPoint] = []
            results?.enumerateStatistics(from: start, to: end) { stats, _ in
                let q: HKQuantity? = (options == .cumulativeSum)
                    ? stats.sumQuantity()
                    : stats.averageQuantity()
                out.append(DataPoint(date: stats.startDate,
                                     value: (q?.doubleValue(for: unit)) ?? 0))
            }
            DispatchQueue.main.async { completion(out) }
        }

        healthStore.execute(query)
    }

    func fetchDailyAsleepHoursSeries(daysBack: Int = 14,
                                     completion: @escaping ([DataPoint]) -> Void) {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([]); return
        }

        let cal = Calendar.current
        let end = cal.startOfDay(for: Date())
        guard let start = cal.date(byAdding: .day, value: -daysBack, to: end) else {
            completion([]); return
        }

        let predicate = HKQuery.predicateForSamples(withStart: start,
                                                    end: end.addingTimeInterval(24*3600),
                                                    options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let q = HKSampleQuery(sampleType: type,
                              predicate: predicate,
                              limit: HKObjectQueryNoLimit,
                              sortDescriptors: [sort]) { _, results, _ in
            let samples = (results as? [HKCategorySample]) ?? []
            var buckets: [Date: TimeInterval] = [:]

            for s in samples {
                // exclude Awake (2) & InBed (0); everything else counts as asleep
                if s.value == 2 || s.value == 0 { continue }
                let key = cal.startOfDay(for: s.startDate)
                buckets[key, default: 0] += s.endDate.timeIntervalSince(s.startDate)
            }

            var out: [DataPoint] = []
            var d = start
            while d < end {
                out.append(DataPoint(date: d,
                                     value: (buckets[d] ?? 0) / 3600.0))
                d = cal.date(byAdding: .day, value: 1, to: d)!
            }

            DispatchQueue.main.async { completion(out) }
        }

        healthStore.execute(q)
    }
    
    func fetchHeartRateDuringSleep(
        sleepSegments: [SleepSegment],
        completion: @escaping ([DataPoint]) -> Void
    ) {
        guard !sleepSegments.isEmpty,
              let sleepStart = sleepSegments.map({ $0.start }).min(),
              let sleepEnd = sleepSegments.map({ $0.end }).max(),
              let hrType = HKObjectType.quantityType(forIdentifier: .heartRate)
        else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: sleepStart,
            end: sleepEnd,
            options: .strictStartDate
        )
        
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(
            sampleType: hrType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sort]
        ) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample] else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            let hrUnit = HKUnit(from: "count/min")
            let points = samples.map { sample in
                DataPoint(
                    date: sample.startDate,
                    value: sample.quantity.doubleValue(for: hrUnit)
                )
            }
            
            DispatchQueue.main.async { completion(points) }
        }
        
        healthStore.execute(query)
    }
    
    /// Fetch multiple metrics during sleep time
    func fetchMetricsDuringSleep(
        sleepSegments: [SleepSegment],
        metrics: [HKQuantityTypeIdentifier],
        completion: @escaping ([HKQuantityTypeIdentifier: [DataPoint]]) -> Void
    ) {
        guard !sleepSegments.isEmpty,
              let sleepStart = sleepSegments.map({ $0.start }).min(),
              let sleepEnd = sleepSegments.map({ $0.end }).max()
        else {
            completion([:])
            return
        }
        
        var results: [HKQuantityTypeIdentifier: [DataPoint]] = [:]
        let group = DispatchGroup()
        
        for identifier in metrics {
            guard let qType = HKObjectType.quantityType(forIdentifier: identifier) else {
                continue
            }
            
            group.enter()
            
            let predicate = HKQuery.predicateForSamples(
                withStart: sleepStart,
                end: sleepEnd,
                options: .strictStartDate
            )
            
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            
            let query = HKSampleQuery(
                sampleType: qType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                defer { group.leave() }
                
                guard let samples = samples as? [HKQuantitySample] else { return }
                
                let unit = self.unitFor(identifier: identifier)
                let points = samples.map { sample in
                    DataPoint(
                        date: sample.startDate,
                        value: sample.quantity.doubleValue(for: unit)
                    )
                }
                
                results[identifier] = points
            }
            
            healthStore.execute(query)
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
    
    // Helper to get appropriate unit for each metric
    private func unitFor(identifier: HKQuantityTypeIdentifier) -> HKUnit {
        switch identifier {
        case .heartRate, .restingHeartRate, .respiratoryRate:
            return HKUnit(from: "count/min")
        case .heartRateVariabilitySDNN:
            return HKUnit.secondUnit(with: .milli)
        case .oxygenSaturation:
            return HKUnit.percent()
        default:
            return HKUnit.count()
        }
    }
}
