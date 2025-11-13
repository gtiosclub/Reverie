// HealthKitViewModel.swift

import Foundation
import HealthKit

@MainActor
final class HealthKitViewModel: ObservableObject {
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

    // Series for charts
    enum MetricKey: String, CaseIterable, Identifiable {
        case date, heartRate, restingHeartRate, stepCount, distanceKm, activeEnergy, asleepHours
        var id: String { rawValue }
        var label: String {
            switch self {
            case .date:           return "Date"
            case .heartRate:      return "Heart Rate (avg bpm)"
            case .restingHeartRate: return "Resting HR (avg bpm)"
            case .stepCount:      return "Steps (daily)"
            case .distanceKm:     return "Distance (km, daily)"
            case .activeEnergy:   return "Active Energy (kcal, daily)"
            case .asleepHours:    return "Asleep (hrs, daily)"
            }
        }
    }

    @Published var series: [MetricKey: [HealthKitManager.DataPoint]] = [:]

    // MARK: Real data flow
    func requestAndFetch() {
        #if targetEnvironment(simulator)
        self.loadMockForPreview()
        return
        #endif

        manager.requestAuthorization { [weak self] success, error in
            guard let self else { return }
            if success {
                Task { @MainActor in
                    self.fetchAllMetrics()
                    self.loadDefaultSeries()
                }
            } else {
                print("Authorization failed:", error?.localizedDescription ?? "unknown")
            }
        }
    }

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
                self.distanceWalkingRunning =
                    String(format: "%.2f",
                           s.quantity.doubleValue(for: HKUnit.meterUnit(with: .kilo)))
            }
        }
        manager.fetchMostRecentQuantity(for: .activeEnergyBurned) { s in
            if let s {
                self.activeEnergy =
                    String(format: "%.0f",
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

        manager.fetchMostRecentQuantity(for: .respiratoryRate) { s in
            if let s {
                self.respiratoryRate =
                    String(format: "%.1f",
                           s.quantity.doubleValue(for: HKUnit(from: "count/min")))
            }
        }
        manager.fetchMostRecentQuantity(for: .oxygenSaturation) { s in
            if let s {
                self.oxygenSaturation =
                    String(format: "%.0f%%",
                           s.quantity.doubleValue(for: .percent()))
            }
        }
        manager.fetchMostRecentQuantity(for: .heartRateVariabilitySDNN) { s in
            if let s {
                self.hrv =
                    String(format: "%.1f",
                           s.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)))
            }
        }
    }

    func loadDefaultSeries(daysBack: Int = 14) {
        manager.fetchDailyQuantitySeries(identifier: .heartRate,
                                         unit: HKUnit(from: "count/min"),
                                         daysBack: daysBack,
                                         options: .discreteAverage) {
            self.series[.heartRate] = $0
        }
        manager.fetchDailyQuantitySeries(identifier: .restingHeartRate,
                                         unit: HKUnit(from: "count/min"),
                                         daysBack: daysBack,
                                         options: .discreteAverage) {
            self.series[.restingHeartRate] = $0
        }
        manager.fetchDailyQuantitySeries(identifier: .stepCount,
                                         unit: .count(),
                                         daysBack: daysBack,
                                         options: .cumulativeSum) {
            self.series[.stepCount] = $0
        }
        manager.fetchDailyQuantitySeries(identifier: .distanceWalkingRunning,
                                         unit: HKUnit.meterUnit(with: .kilo),
                                         daysBack: daysBack,
                                         options: .cumulativeSum) {
            self.series[.distanceKm] = $0
        }
        manager.fetchDailyQuantitySeries(identifier: .activeEnergyBurned,
                                         unit: .kilocalorie(),
                                         daysBack: daysBack,
                                         options: .cumulativeSum) {
            self.series[.activeEnergy] = $0
        }
        manager.fetchDailyAsleepHoursSeries(daysBack: daysBack) {
            self.series[.asleepHours] = $0
        }
    }

    // MARK: Preview / simulator mock data
    func loadMockForPreview() {
        heartRate = "72"
        restingHeartRate = "58"
        stepCount = "8,412"
        distanceWalkingRunning = "6.4"
        activeEnergy = "435"
        sleepDuration = "7.1"
        inBedTime = "7.8"
        remHours = "1.5"
        deepHours = "1.2"
        coreHours = "4.4"
        totalSleepHours = "7.1"
        awakenings = "3"
        respiratoryRate = "14.8"
        oxygenSaturation = "98%"
        hrv = "58.3"

        let cal = Calendar.current
        let start = cal.startOfDay(for: Date().addingTimeInterval(-13*24*3600))

        func mk(_ base: Double, _ jitter: Double) -> [HealthKitManager.DataPoint] {
            (0..<14).map { i in
                let d = cal.date(byAdding: .day, value: i, to: start)!
                let v = base + Double.random(in: -jitter...jitter)
                return HealthKitManager.DataPoint(date: d, value: max(0, v))
            }
        }

        series[.heartRate]       = mk(72,    6)
        series[.restingHeartRate]= mk(58,    4)
        series[.stepCount]       = mk(9000,  2500)
        series[.distanceKm]      = mk(6.2,   2.0)
        series[.activeEnergy]    = mk(450,   120)
        series[.asleepHours]     = mk(7.0,   1.0)
    }
}
