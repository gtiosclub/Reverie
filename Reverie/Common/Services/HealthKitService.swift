//
//  HealthKitService.swift
//  Reverie
//

import HealthKit


final class HealthKitService {
    static let shared = HealthKitService()
    private let healthStore = HKHealthStore()

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false)
            return
        }

        healthStore.requestAuthorization(
            toShare: [],
            read: [sleepType]
        ) { success, _ in
            completion(success)
        }
    }

    func getSleepTimes() async -> SleepTime? {
        return await getAverageSleepTimesForPastWeek()
    }

    private func getAverageSleepTimesForPastWeek() async -> SleepTime? {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return nil
        }

        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        let predicate = HKQuery.predicateForSamples(
            withStart: sevenDaysAgo,
            end: Date(),
            options: []
        )

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, results, error in

                if let error = error {
                    print("❌ Sleep query error:", error.localizedDescription)
                    continuation.resume(returning: nil)
                    return
                }

                guard let samples = results as? [HKCategorySample], !samples.isEmpty else {
                    print("⚠️ No sleep samples found for past week.")
                    continuation.resume(returning: nil)
                    return
                }

                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]

                let asleepSamples = samples.filter { asleepValues.contains($0.value) }

                if asleepSamples.isEmpty {
                    print("⚠️ No asleep samples found.")
                    continuation.resume(returning: nil)
                    return
                }

                let groupedByNight = Dictionary(grouping: asleepSamples) {
                    calendar.startOfDay(for: $0.startDate)
                }

                var bedtimes: [Date] = []
                var wakeTimes: [Date] = []

                for (_, nightsSamples) in groupedByNight {
                    if let first = nightsSamples.first,
                       let last = nightsSamples.last {
                        bedtimes.append(first.startDate)
                        wakeTimes.append(last.endDate)
                    }
                }

                guard !bedtimes.isEmpty, !wakeTimes.isEmpty else {
                    continuation.resume(returning: nil)
                    return
                }

                let averageBed = HealthKitService.averageDate(bedtimes)
                let averageWake = HealthKitService.averageDate(wakeTimes)

                print("📊 Weekly Average Bedtime:", averageBed)
                print("📊 Weekly Average Wake Time:", averageWake)

                continuation.resume(
                    returning: SleepTime(bedtime: averageBed, wakeUpTime: averageWake)
                )
            }

            self.healthStore.execute(query)
        }
    }

    static func averageDate(_ dates: [Date]) -> Date {
        let total = dates.reduce(0.0) { $0 + $1.timeIntervalSince1970 }
        let mean = total / Double(dates.count)
        return Date(timeIntervalSince1970: mean)
    }
}
