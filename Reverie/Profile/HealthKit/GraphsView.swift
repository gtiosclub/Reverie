// GraphsView.swift

import SwiftUI
import Charts

struct GraphsView: View {
    @ObservedObject var vm: HealthKitViewModel

    /// Sleep is always shown; these are extra metrics to overlay.
    private let compareCandidates: [HealthKitViewModel.MetricKey] = [
        .heartRate,
        .restingHeartRate,
        .stepCount,
        .distanceKm,
        .activeEnergy
    ]

    @State private var selectedComparisons: Set<HealthKitViewModel.MetricKey> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 4) {
                Text("Sleep")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("Compare your sleep to other health metrics.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            VStack(spacing: 12) {
                MultiMetricLineChart(
                    series: vm.series,
                    baseMetric: .asleepHours,
                    comparisonMetrics: Array(selectedComparisons)
                )
                .frame(minHeight: 230)
            }
            .padding(14)
            .background(Theme.cardHi, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Theme.gridLine, lineWidth: 1)
            )

            Text("Compare to")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.8))

            FlexibleButtonGrid(
                allMetrics: compareCandidates,
                selected: $selectedComparisons
            )
        }
        .padding(.top, 8)
        .onAppear {
            if PreviewEnv.isPreview {
                vm.loadMockForPreview()
            } else if vm.series.isEmpty {
                vm.loadDefaultSeries(daysBack: 14)
            }
        }
    }
}

// MARK: - Multi-metric Line Chart

private struct MultiMetricLineChart: View {
    let series: [HealthKitViewModel.MetricKey: [HealthKitManager.DataPoint]]
    let baseMetric: HealthKitViewModel.MetricKey
    let comparisonMetrics: [HealthKitViewModel.MetricKey]

    struct CombinedPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let metricLabel: String
    }

    private var allPoints: [CombinedPoint] {
        var points: [CombinedPoint] = []

        func appendSeries(for key: HealthKitViewModel.MetricKey) {
            guard let s = series[key] else { return }
            for dp in s {
                points.append(
                    CombinedPoint(date: dp.date,
                                  value: dp.value,
                                  metricLabel: key.label)
                )
            }
        }

        appendSeries(for: baseMetric)
        comparisonMetrics.forEach { appendSeries(for: $0) }

        return points
    }

    var body: some View {
        Chart(allPoints) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .lineStyle(.init(lineWidth: 2))
            .interpolationMethod(.catmullRom)
            .foregroundStyle(by: .value("Metric", point.metricLabel))

            PointMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .symbolSize(18)
            .foregroundStyle(by: .value("Metric", point.metricLabel))
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine().foregroundStyle(Theme.gridLine)
                AxisTick().foregroundStyle(.white.opacity(0.4))
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(shortDate(date))
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine().foregroundStyle(Theme.gridLine)
                AxisTick().foregroundStyle(.white.opacity(0.4))
                AxisValueLabel()
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.caption2)
            }
        }
        .chartLegend(position: .bottom)
        .padding(.horizontal, 4)
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

// MARK: - Compare buttons

private struct FlexibleButtonGrid: View {
    let allMetrics: [HealthKitViewModel.MetricKey]
    @Binding var selected: Set<HealthKitViewModel.MetricKey>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
            ForEach(allMetrics) { metric in
                let isOn = selected.contains(metric)

                Button {
                    if isOn { selected.remove(metric) } else { selected.insert(metric) }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: icon(for: metric))
                        Text(buttonTitle(for: metric))
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isOn ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isOn ? Color.white.opacity(0.6) : Theme.gridLine,
                                    lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func buttonTitle(for key: HealthKitViewModel.MetricKey) -> String {
        switch key {
        case .heartRate:         return "Heart Rate"
        case .restingHeartRate:  return "Resting HR"
        case .stepCount:         return "Steps"
        case .distanceKm:        return "Distance"
        case .activeEnergy:      return "Active Energy"
        case .asleepHours, .date:
            return key.label
        }
    }

    private func icon(for key: HealthKitViewModel.MetricKey) -> String {
        switch key {
        case .heartRate, .restingHeartRate: return "heart.fill"
        case .stepCount:                    return "figure.walk"
        case .distanceKm:                   return "map.fill"
        case .activeEnergy:                 return "flame.fill"
        case .asleepHours:                  return "moon.zzz.fill"
        case .date:                         return "calendar"
        }
    }
}
