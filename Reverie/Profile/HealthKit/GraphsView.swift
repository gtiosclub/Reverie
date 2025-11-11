import SwiftUI
import Charts

struct GraphsView: View {
    @ObservedObject var vm: HealthKitViewModel
    @State private var mode: Mode = .timeSeries
    @State private var xMetric: HealthKitViewModel.MetricKey = .date
    @State private var yMetric: HealthKitViewModel.MetricKey = .stepCount
    @State private var daysBack: Int = 14

    enum Mode: String, CaseIterable, Identifiable { case timeSeries = "Time Series", scatter = "Scatter"; var id: String { rawValue } }

    var body: some View {
        VStack(spacing: 12) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            HStack {
                VStack(alignment: .leading) {
                    Text("X Axis").font(.caption)
                    Picker("X Axis", selection: $xMetric) {
                        Text(HealthKitViewModel.MetricKey.date.label).tag(HealthKitViewModel.MetricKey.date)
                        ForEach(HealthKitViewModel.MetricKey.allCases.filter { $0 != .date }) {
                            Text($0.label).tag($0)
                        }
                    }.pickerStyle(.menu)
                }
                VStack(alignment: .leading) {
                    Text("Y Axis").font(.caption)
                    Picker("Y Axis", selection: $yMetric) {
                        ForEach(HealthKitViewModel.MetricKey.allCases.filter { $0 != .date }) {
                            Text($0.label).tag($0)
                        }
                    }.pickerStyle(.menu)
                }
            }

            HStack {
                Stepper("Days: \(daysBack)", value: $daysBack, in: 7...60)
                Spacer()
                Button("Load Data") { vm.loadDefaultSeries(daysBack: daysBack) }
                    .buttonStyle(.borderedProminent)
            }

            Group {
                if mode == .timeSeries {
                    TimeSeriesChart(points: vm.series[yMetric] ?? [], title: yMetric.label)
                } else {
                    ScatterChart(xPoints: vm.series[xMetric] ?? [],
                                 yPoints: vm.series[yMetric] ?? [],
                                 xLabel: xMetric.label, yLabel: yMetric.label)
                }
            }
            .frame(minHeight: 260)

            Spacer()
        }
        .padding(.vertical, 8)
        .onAppear { vm.loadDefaultSeries(daysBack: daysBack) }
    }
}

// MARK: - Charts
private struct TimeSeriesChart: View {
    let points: [HealthKitManager.DataPoint]
    let title: String
    var body: some View {
        Chart(points) {
            LineMark(x: .value("Date", $0.date), y: .value(title, $0.value))
            PointMark(x: .value("Date", $0.date), y: .value(title, $0.value))
        }
        .chartXAxisLabel("Date")
        .chartYAxisLabel(title)
    }
}

private struct ScatterChart: View {
    struct ScatterPoint: Identifiable { let id = UUID(); let x: Double; let y: Double }
    let xPoints: [HealthKitManager.DataPoint]
    let yPoints: [HealthKitManager.DataPoint]
    let xLabel: String, yLabel: String

    var paired: [ScatterPoint] {
        let cal = Calendar.current
        let xm = Dictionary(uniqueKeysWithValues: xPoints.map { (cal.startOfDay(for: $0.date), $0.value) })
        let ym = Dictionary(uniqueKeysWithValues: yPoints.map { (cal.startOfDay(for: $0.date), $0.value) })
        let days = Set(xm.keys).intersection(ym.keys).sorted()
        return days.map { ScatterPoint(x: xm[$0] ?? 0, y: ym[$0] ?? 0) }
    }

    var body: some View {
        Chart(paired) { p in
            PointMark(x: .value(xLabel, p.x), y: .value(yLabel, p.y))
        }
        .chartXAxisLabel(xLabel)
        .chartYAxisLabel(yLabel)
    }
}
