import SwiftUI
import Charts

struct HealthKitSleepDashboardView: View {
    @StateObject private var vm: HealthKitSleepViewModel = HealthKitSleepViewModel()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.02, blue: 0.20),
                    Color(red: 0.03, green: 0.01, blue: 0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // Top sleep card (graph + compare buttons)
                    SleepGraphsSection(vm: vm)
                        .padding(.top, 8)

                    // Metric cards below
                    VStack(spacing: 24) {
                        MetricSection(title: "Health Metrics") {
                            MetricRow(label: "Heart Rate (bpm)", value: vm.heartRate)
                            MetricRow(label: "Resting HR (bpm)", value: vm.restingHeartRate)
                            MetricRow(label: "Steps", value: vm.stepCount)
                            MetricRow(label: "Distance (km)", value: vm.distanceWalkingRunning)
                            MetricRow(label: "Active Energy (kcal)", value: vm.activeEnergy)
                        }

                        MetricSection(title: "Sleep — Previous Night") {
                            MetricRow(label: "Asleep (hrs)", value: vm.sleepDuration)
                            MetricRow(label: "In Bed (hrs)", value: vm.inBedTime)
                            MetricRow(label: "REM (hrs)", value: vm.remHours)
                            MetricRow(label: "Deep (hrs)", value: vm.deepHours)
                            MetricRow(label: "Core (hrs)", value: vm.coreHours)
                            MetricRow(label: "Awakenings", value: vm.awakenings)
                            MetricRow(label: "Total (hrs)", value: vm.totalSleepHours)
                        }

                        MetricSection(title: "Sleep-related Signals") {
                            MetricRow(label: "Respiratory Rate (min⁻¹)", value: vm.respiratoryRate)
                            MetricRow(label: "Oxygen Saturation", value: vm.oxygenSaturation)
                            MetricRow(label: "HRV SDNN (ms)", value: vm.hrv)
                        }
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear { vm.requestAndFetch() }
    }
}

#Preview {
    HealthKitSleepDashboardView()   // uses dummy data in previews
}

// MARK: - Top Sleep Card (graphs + buttons)

private struct SleepGraphsSection: View {
    @ObservedObject var vm: HealthKitSleepViewModel

    @State private var selectedMetric: HealthKitSleepViewModel.MetricKey? = .heartRate
    @State private var daysBack: Int = 14

    private let compareMetrics: [HealthKitSleepViewModel.MetricKey] = [
        .heartRate, .restingHeartRate, .stepCount, .distanceKm, .activeEnergy, .asleepHours
    ]

    private var overlayPoints: [HealthKitManager.DataPoint] {
        guard let key = selectedMetric else { return [] }
        // For now use daily series; you can later swap to intranight data if you add it
        return vm.series[key] ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {

            // Title
            Text("Sleep")
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            // REM summary
            Text(remSummaryText)
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)

            // Date pill
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(.white)
                Text(previousNightString)
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.06))
            )

            // --- BIG GRAPH CARD (explicit height so it can't collapse) ---
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.45))

                if vm.previousNightSegments.isEmpty {
                    Text("Sleep stages will appear here once data loads.")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        SleepOverlayChart(
                            segments: vm.previousNightSegments,
                            metricPoints: overlayPoints
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        HStack(spacing: 16) {
                            legendDot(color: sleepStageColor("Awake"), label: "Awake")
                            legendDot(color: sleepStageColor("REM"), label: "REM")
                            legendDot(color: sleepStageColor("Core"), label: "Core")
                            legendDot(color: sleepStageColor("Deep"), label: "Deep")
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
                    }
                    .padding(16)
                }
            }
            .frame(maxWidth: .infinity,
                   minHeight: 260,
                   maxHeight: 320)

            Spacer(minLength: 12)

            // --- COMPARE SECTION BELOW THE GRAPH ---
            VStack(alignment: .leading, spacing: 14) {
                Text("Compare to")
                    .font(.headline)
                    .foregroundColor(.white)

                let cols = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(compareMetrics, id: \.self) { metric in
                        MetricButton(
                            title: metricTitle(metric),
                            systemImage: metricIcon(metric),
                            isSelected: selectedMetric == metric
                        ) {
                            if selectedMetric == metric {
                                selectedMetric = nil
                            } else {
                                selectedMetric = metric
                            }
                        }
                    }
                }

                // Days slider (for daily series)
                HStack {
                    Text("Last \(daysBack) days")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.footnote)
                    Spacer()
                    Stepper("", value: $daysBack, in: 7...60, step: 7) { _ in
                        vm.loadDefaultSeries(daysBack: daysBack)
                    }
                    .labelsHidden()
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.04))
        )
    }

    // MARK: helpers

    private var previousNightString: String {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return formatter.string(from: yesterday)
    }

    private var remSummaryText: String {
        guard let hours = Double(vm.remHours) else {
            return "REM sleep data will appear here once available."
        }
        let h = Int(hours)
        let minutes = Int((hours - Double(h)) * 60.0)
        if h == 0 && minutes == 0 {
            return "No REM sleep recorded last night."
        }
        return "You spent \(h) hours and \(minutes) minutes in REM sleep last night."
    }

    private func metricTitle(_ key: HealthKitSleepViewModel.MetricKey) -> String {
        switch key {
        case .heartRate:        return "Heart Rate"
        case .restingHeartRate: return "Resting HR"
        case .stepCount:        return "Steps"
        case .distanceKm:       return "Distance"
        case .activeEnergy:     return "Active Energy"
        case .asleepHours:      return "Sleep Duration"
        default:                return key.label
        }
    }

    private func metricIcon(_ key: HealthKitSleepViewModel.MetricKey) -> String {
        switch key {
        case .heartRate, .restingHeartRate: return "heart.fill"
        case .stepCount:                    return "figure.walk"
        case .distanceKm:                   return "map"
        case .activeEnergy:                 return "flame.fill"
        case .asleepHours:                  return "bed.double.fill"
        default:                            return "waveform.path.ecg"
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Reusable metric components

private struct MetricSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            VStack(spacing: 8) { content }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.06))
                )
        }
    }
}

private struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .foregroundColor(.cyan)
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}

private struct MetricButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? Color.white.opacity(0.25)
                                     : Color.white.opacity(0.08))
            )
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Charts helpers

/// Shared stage color so the overlay + legend stay consistent.
private func sleepStageColor(_ stage: String) -> Color {
    switch stage {
    case "Awake":
        return Color(red: 0.99, green: 0.57, blue: 0.18)
    case "REM":
        return Color(red: 0.96, green: 0.28, blue: 0.64)
    case "Core", "Asleep":
        return Color(red: 0.35, green: 0.78, blue: 0.47)
    case "Deep":
        return Color(red: 0.24, green: 0.55, blue: 0.97)
    case "In Bed":
        return Color.white.opacity(0.15)
    default:
        return Color.white.opacity(0.3)
    }
}

/// BIG combined chart: multi-row sleep map background + optional metric line/area overlay.
private struct SleepOverlayChart: View {
    let segments: [HealthKitManager.SleepSegment]
    let metricPoints: [HealthKitManager.DataPoint]

    // Shared x-domain so bars and line line up in time
    private var xDomain: ClosedRange<Date>? {
        let segDates = segments.flatMap { [$0.start, $0.end] }
        let metricDates = metricPoints.map { $0.date }
        let all = segDates + metricDates
        guard let minDate = all.min(), let maxDate = all.max() else {
            return nil
        }
        return minDate...maxDate
    }

    var body: some View {
        ZStack {
            // BACKGROUND: sleep stages, multiple rows (Awake / REM / Core / Deep)
            if !segments.isEmpty {
                Chart(segments, id: \.start) { seg in
                    BarMark(
                        xStart: .value("Start", seg.start),
                        xEnd: .value("End", seg.end),
                        y: .value("Stage", seg.stage)
                    )
                    .cornerRadius(4)
                    .foregroundStyle(sleepStageColor(seg.stage))
                }
                .chartXScale(domain: xDomain ?? defaultDomain)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(Self.hourFormatter.string(from: date))
                            }
                        }
                    }
                }
                .chartLegend(.hidden)
                .chartPlotStyle { plot in
                    plot.background(.clear)
                }
                .allowsHitTesting(false)
            }

            // FOREGROUND: selected metric as a filled “graph” + line
            if !metricPoints.isEmpty {
                Chart(metricPoints) { point in
                    AreaMark(
                        x: .value("Time", point.date),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .opacity(0.35)

                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.0, lineCap: .round))
                    .symbol(.circle)
                }
                .chartXScale(domain: xDomain ?? defaultDomain)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartPlotStyle { plot in
                    plot.background(.clear)
                }
            }
        }
    }

    // Fallback domain if we somehow have no data
    private var defaultDomain: ClosedRange<Date> {
        let now = Date()
        let later = Calendar.current.date(byAdding: .hour, value: 8, to: now) ?? now
        return now...later
    }

    private static let hourFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
}
