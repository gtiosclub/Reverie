import Foundation
import HealthKit
import Combine

@MainActor
final class HealthKitSleepViewModel: ObservableObject {
    private let manager = HealthKitManager()

    // Snapshot metrics
    @Published var heartRate = "-"
    @Published var restingHeartRate = "-"
    @Published var stepCount = "-"
    @Published var distanceWalkingRunning = "-"
    @Published var activeEnergy = "-"
    @Published var sleepDuration = "-"
    @Published var inBedTime = "-"
    @Published var remHours = "-"
    @Published var deepHours = "-"
    @Published var coreHours = "-"
    @Published var totalSleepHours = "-"
    @Published var awakenings = "-"
    @Published var respiratoryRate = "-"
    @Published var oxygenSaturation = "-"
    @Published var hrv = "-"

    // For the sleep-stage timeline chart
    @Published var previousNightSegments: [HealthKitManager.SleepSegment] = []

    // Time-series data for charts
    enum MetricKey: String, CaseIterable, Identifiable {
        case date, heartRate, restingHeartRate, stepCount, distanceKm, activeEnergy, asleepHours
        var id: String { rawValue }
        var label: String {
            switch self {
            case .date:            return "Date"
            case .heartRate:       return "Heart Rate (avg bpm)"
            case .restingHeartRate:return "Resting HR (avg bpm)"
            case .stepCount:       return "Steps (daily)"
            case .distanceKm:      return "Distance (km, daily)"
            case .activeEnergy:    return "Active Energy (kcal, daily)"
            case .asleepHours:     return "Asleep (hrs, daily)"
            }
        }
    }

    @Published var series: [MetricKey: [HealthKitManager.DataPoint]] = [:]

    // MARK: - Public API

    func requestAndFetch() {
        // Use dummy data in Xcode previews
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if isPreview {
            loadDummyData()
            return
        }

        manager.requestAuthorization { [weak self] success, error in
            guard let self else { return }

            if success {
                self.fetchAllMetrics()
                self.loadDefaultSeries()
            } else {
                print("HealthKit authorization failed:", error?.localizedDescription ?? "unknown")
                self.loadDummyData()
            }
        }
    }

    func loadDefaultSeries(daysBack: Int = 14) {
        manager.fetchDailyQuantitySeries(
            identifier: .heartRate,
            unit: HKUnit(from: "count/min"),
            daysBack: daysBack,
            options: .discreteAverage
        ) { self.series[.heartRate] = $0 }

        manager.fetchDailyQuantitySeries(
            identifier: .restingHeartRate,
            unit: HKUnit(from: "count/min"),
            daysBack: daysBack,
            options: .discreteAverage
        ) { self.series[.restingHeartRate] = $0 }

        manager.fetchDailyQuantitySeries(
            identifier: .stepCount,
            unit: .count(),
            daysBack: daysBack,
            options: .cumulativeSum
        ) { self.series[.stepCount] = $0 }

        manager.fetchDailyQuantitySeries(
            identifier: .distanceWalkingRunning,
            unit: HKUnit.meterUnit(with: .kilo),
            daysBack: daysBack,
            options: .cumulativeSum
        ) { self.series[.distanceKm] = $0 }

        manager.fetchDailyQuantitySeries(
            identifier: .activeEnergyBurned,
            unit: .kilocalorie(),
            daysBack: daysBack,
            options: .cumulativeSum
        ) { self.series[.activeEnergy] = $0 }

        manager.fetchDailyAsleepHoursSeries(daysBack: daysBack) {
            self.series[.asleepHours] = $0
        }
    }

    // MARK: - Real HK calls

    private func fetchAllMetrics() {
        manager.fetchMostRecentQuantity(for: .heartRate) { s in
            if let s {
                self.heartRate = String(format: "%.0f",
                    s.quantity.doubleValue(for: HKUnit(from: "count/min")))
            }
        }

        manager.fetchMostRecentQuantity(for: .restingHeartRate) { s in
            if let s {
                self.restingHeartRate = String(format: "%.0f",
                    s.quantity.doubleValue(for: HKUnit(from: "count/min")))
            }
        }

        manager.fetchMostRecentQuantity(for: .stepCount) { s in
            if let s {
                self.stepCount = String(format: "%.0f",
                    s.quantity.doubleValue(for: .count()))
            }
        }

        manager.fetchMostRecentQuantity(for: .distanceWalkingRunning) { s in
            if let s {
                self.distanceWalkingRunning = String(format: "%.2f",
                    s.quantity.doubleValue(for: HKUnit.meterUnit(with: .kilo)))
            }
        }

        manager.fetchMostRecentQuantity(for: .activeEnergyBurned) { s in
            if let s {
                self.activeEnergy = String(format: "%.0f",
                    s.quantity.doubleValue(for: .kilocalorie()))
            }
        }

        manager.fetchPreviousNightSleepBreakdown { b in
            guard let b else { return }
            self.remHours        = String(format: "%.1f", b.remHours)
            self.deepHours       = String(format: "%.1f", b.deepHours)
            self.coreHours       = String(format: "%.1f", b.coreHours)
            self.totalSleepHours = String(format: "%.1f", b.remHours + b.deepHours + b.coreHours)
            self.awakenings      = "\(b.awakeningsCount)"
            self.sleepDuration   = String(format: "%.1f", b.asleepHours)
            self.inBedTime       = String(format: "%.1f", b.inBedHours)
        }

        loadPreviousNightSegments()

        manager.fetchMostRecentQuantity(for: .respiratoryRate) { s in
            if let s {
                self.respiratoryRate = String(format: "%.1f",
                    s.quantity.doubleValue(for: HKUnit(from: "count/min")))
            }
        }

        manager.fetchMostRecentQuantity(for: .oxygenSaturation) { s in
            if let s {
                self.oxygenSaturation = String(format: "%.0f%%",
                    s.quantity.doubleValue(for: .percent()))
            }
        }

        manager.fetchMostRecentQuantity(for: .heartRateVariabilitySDNN) { s in
            if let s {
                self.hrv = String(format: "%.1f",
                    s.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)))
            }
        }
    }

    private func loadPreviousNightSegments() {
        let cal = Calendar.current
        let now = Date()
        guard
            let start = cal.date(bySettingHour: 18, minute: 0, second: 0,
                                 of: now.addingTimeInterval(-86400)),
            let end   = cal.date(bySettingHour: 10, minute: 0, second: 0, of: now)
        else { return }

        manager.fetchSleepSegments(start: start, end: end, onlyAppleHealthSource: true) { segs in
            self.previousNightSegments = segs
        }
    }

    // MARK: - Dummy data (for previews / auth failure)

    private func loadDummyData(daysBack: Int = 14) {
        heartRate = "72"
        restingHeartRate = "60"
        stepCount = "8643"
        distanceWalkingRunning = "6.4"
        activeEnergy = "550"

        remHours = "2.3"
        deepHours = "1.5"
        coreHours = "3.0"
        totalSleepHours = "6.8"
        awakenings = "4"
        sleepDuration = totalSleepHours
        inBedTime = "7.5"

        respiratoryRate = "15.2"
        oxygenSaturation = "98%"
        hrv = "72.3"

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var hrPoints: [HealthKitManager.DataPoint] = []
        var rhrPoints: [HealthKitManager.DataPoint] = []
        var stepPoints: [HealthKitManager.DataPoint] = []
        var distPoints: [HealthKitManager.DataPoint] = []
        var energyPoints: [HealthKitManager.DataPoint] = []
        var sleepPoints: [HealthKitManager.DataPoint] = []

        for i in 0..<daysBack {
            guard let day = cal.date(byAdding: .day, value: -i, to: today) else { continue }
            let t = Double(i)
            let hr = 68 + sin(t / 2.0) * 5
            let rhr = 58 + cos(t / 3.0) * 3
            let steps = 6000 + Int.random(in: 0...4000)
            let dist = Double(steps) / 1300.0
            let energy = 450 + Int.random(in: 0...300)
            let sleep = 6.0 + sin(t / 3.5) * 0.7

            hrPoints.append(.init(date: day, value: hr))
            rhrPoints.append(.init(date: day, value: rhr))
            stepPoints.append(.init(date: day, value: Double(steps)))
            distPoints.append(.init(date: day, value: dist))
            energyPoints.append(.init(date: day, value: Double(energy)))
            sleepPoints.append(.init(date: day, value: sleep))
        }

        series[.heartRate] = hrPoints.reversed()
        series[.restingHeartRate] = rhrPoints.reversed()
        series[.stepCount] = stepPoints.reversed()
        series[.distanceKm] = distPoints.reversed()
        series[.activeEnergy] = energyPoints.reversed()
        series[.asleepHours] = sleepPoints.reversed()

        previousNightSegments = makeDummySleepSegments()
    }

    private func makeDummySleepSegments() -> [HealthKitManager.SleepSegment] {
        let cal = Calendar.current
        let now = Date()

        guard let nightStart = cal.date(bySettingHour: 23,
                                        minute: 0,
                                        second: 0,
                                        of: now.addingTimeInterval(-86400)) else {
            return []
        }

        let blocks: [(Int, String, Int)] = [
            (30,  "Awake", 2),
            (60,  "Core",  3),
            (45,  "REM",   5),
            (90,  "Deep",  4),
            (60,  "Core",  3),
            (40,  "REM",   5),
            (35,  "Awake", 2),
            (60,  "Core",  3)
        ]

        var segments: [HealthKitManager.SleepSegment] = []
        var cursor = nightStart

        for block in blocks {
            let duration = TimeInterval(block.0 * 60)
            let end = cursor.addingTimeInterval(duration)
            let hours = duration / 3600.0

            segments.append(
                HealthKitManager.SleepSegment(
                    start: cursor,
                    end: end,
                    hours: hours,
                    stage: block.1,
                    rawValue: block.2,
                    sourceBundleID: "dummy.reverie.healthkit"
                )
            )
            cursor = end
        }
        return segments
    }
}
