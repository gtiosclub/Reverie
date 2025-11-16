import SwiftUI
import Charts

struct HealthKitSleepDashboardView: View {
    @StateObject private var vm: HealthKitSleepViewModel = HealthKitSleepViewModel()
    

    var body: some View {
        ZStack {
            // Background gradient
//            LinearGradient(
//                colors: [
//                    Color(red: 0.10, green: 0.02, blue: 0.20),
//                    Color(red: 0.03, green: 0.01, blue: 0.10)
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // Top sleep card (graph + compare buttons)
                    SleepGraphsSection(vm: vm)
                        .padding(.top, 8)
//                        .darkGloss()

                    // Metric cards below
//                    VStack(spacing: 24) {
//                        MetricSection(title: "Health Metrics") {
//                            MetricRow(label: "Heart Rate (bpm)", value: vm.heartRate)
//                            MetricRow(label: "Resting HR (bpm)", value: vm.restingHeartRate)
//                            MetricRow(label: "Steps", value: vm.stepCount)
//                            MetricRow(label: "Distance (km)", value: vm.distanceWalkingRunning)
//                            MetricRow(label: "Active Energy (kcal)", value: vm.activeEnergy)
//                        }
//
//                        MetricSection(title: "Sleep — Previous Night") {
//                            MetricRow(label: "Asleep (hrs)", value: vm.sleepDuration)
//                            MetricRow(label: "In Bed (hrs)", value: vm.inBedTime)
//                            MetricRow(label: "REM (hrs)", value: vm.remHours)
//                            MetricRow(label: "Deep (hrs)", value: vm.deepHours)
//                            MetricRow(label: "Core (hrs)", value: vm.coreHours)
//                            MetricRow(label: "Awakenings", value: vm.awakenings)
//                            MetricRow(label: "Total (hrs)", value: vm.totalSleepHours)
//                        }
//
//                        MetricSection(title: "Sleep-related Signals") {
//                            MetricRow(label: "Respiratory Rate (min⁻¹)", value: vm.respiratoryRate)
//                            MetricRow(label: "Oxygen Saturation", value: vm.oxygenSaturation)
//                            MetricRow(label: "HRV SDNN (ms)", value: vm.hrv)
//                        }
//                    }
//                    .padding(.bottom, 32)
                }
//                .padding(.horizontal, 20)
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

    @State private var daysBack: Int = 14
    @State private var selectedMetrics: Set<HealthKitSleepViewModel.MetricKey> = [.intranightHR, .intranightRespRate,] // Allow multiple
//    @State private var selectedDate: Date = Date()
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    @State private var showDatePicker = false


    private let compareMetrics: [HealthKitSleepViewModel.MetricKey] = [
//        .heartRate, .restingHeartRate, .stepCount, .distanceKm, .activeEnergy, .asleepHours
        .intranightHR,
//        .intranightHRV,
        .intranightRespRate,
//        .intranightO2,
    ]

//    private var overlayPoints: [HealthKitManager.DataPoint] {
//        guard let key = selectedMetric else { return [] }
//        return vm.series[key] ?? []
//    }
    
    public var overlayData: [(key: HealthKitSleepViewModel.MetricKey, points: [HealthKitManager.DataPoint], color: Color)] {
        selectedMetrics.compactMap { key in
            guard let points = vm.series[key], !points.isEmpty else { return nil }
            return (key, points, colorForMetric(key))
        }
    }
    

    
    private func colorForMetric(_ key: HealthKitSleepViewModel.MetricKey) -> Color {
         switch key {
         case .intranightHR:     return Color(red: 1.0, green: 0.27, blue: 0.33)  // Red
         case .intranightRespRate: return Color(.indigo)  // Mint green
         case .heartRate:        return Color(red: 1.0, green: 0.4, blue: 0.5)    // Pink
         case .restingHeartRate: return Color(red: 0.8, green: 0.4, blue: 1.0)    // Purple
         case .stepCount:        return Color(red: 0.3, green: 0.9, blue: 0.9)    // Cyan
         case .distanceKm:       return Color(red: 0.2, green: 0.7, blue: 1.0)    // Blue
         case .activeEnergy:     return Color(red: 1.0, green: 0.8, blue: 0.2)    // Yellow
         case .asleepHours:      return Color(red: 0.6, green: 0.5, blue: 1.0)    // Lavender
         default:                return Color.cyan
         }
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
            Button(action: {
                // Show date picker - we'll add this next
                showDatePicker = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.white)
                    Text(previousNightString)
                        .foregroundColor(.white)
                        .font(.subheadline.weight(.medium))
//                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
                )
            }
            .buttonStyle(.plain)

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
                            overlayData: overlayData
                        )
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        HStack(spacing: 16) {
                            legendDot(color: sleepStageColor("Awake"), label: "Awake")
                            legendDot(color: sleepStageColor("REM"), label: "REM")
                            legendDot(color: sleepStageColor("Core"), label: "Core")
                            legendDot(color: sleepStageColor("Deep"), label: "Deep")
//                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
                    }
                    .padding(16)
                }
            }
            .darkGloss()
//            .frame(maxWidth: .infinity,
//                   minHeight: 260,
//                   maxHeight: 320)
            .frame(maxWidth: .infinity,
                   minHeight: 320,
                   maxHeight: 400)


//            Spacer(minLength: 12)

            // --- COMPARE SECTION BELOW THE GRAPH ---
            VStack(alignment: .leading) {
                Text("Compare to")
                    .font(.headline)
                    .foregroundColor(.white)

                let cols = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(compareMetrics, id: \.self) { metric in
                        MetricButton(
                            title: metricTitle(metric),
                            systemImage: metricIcon(metric),
                            isSelected: selectedMetrics.contains(metric),
                            accentColor: colorForMetric(metric)
                        ) {
                            if selectedMetrics.contains(metric) {
                                selectedMetrics.remove(metric)
                            } else {
                                selectedMetrics.insert(metric)
                            }
                        }
                    }
                }

                // Days slider (for daily series)
//                HStack {
//                    Text("Last \(daysBack) days")
//                        .foregroundColor(.white.opacity(0.7))
//                        .font(.footnote)
//                    Spacer()
//                    Stepper("", value: $daysBack, in: 7...60, step: 7) { _ in
//                        vm.loadDefaultSeries(daysBack: daysBack)
//                    }
//                    .labelsHidden()
//                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.04))
        )
        
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate) {
                // When date changes, fetch new data
                vm.loadDataForDate(selectedDate)
            }
        }
    }
    
    private struct DatePickerSheet: View {
        @Environment(\.dismiss) var dismiss
        @Binding var selectedDate: Date
        let onDateChange: () -> Void
        
        var body: some View {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Select Night")
                        .font(.headline)
                        .padding(.top)
                    
                    DatePicker(
                        "Date",
                        selection: $selectedDate,
                        in: ...Date(), // Can't select future dates
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            onDateChange()
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: helpers

    private var previousNightString: String {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return formatter.string(from: selectedDate)
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
        return "You spent \(h) hours and \(minutes) minutes in REM sleep."
    }

//    private func metricTitle(_ key: HealthKitSleepViewModel.MetricKey) -> String {
//        switch key {
//        case .intranightHR:     return "HR During Sleep"
////        case .intranightHRV:    return "HRV During Sleep"
//        case .intranightRespRate: return "Resp Rate"
////        case .intranightO2:     return "O2 Saturation"
//        case .heartRate:        return "Heart Rate"
//        case .restingHeartRate: return "Resting HR"
//        case .stepCount:        return "Steps"
//        case .distanceKm:       return "Distance"
//        case .activeEnergy:     return "Active Energy"
//        case .asleepHours:      return "Sleep Duration"
//            
//        default:                return key.label
//        }
//    }
//
//    private func metricIcon(_ key: HealthKitSleepViewModel.MetricKey) -> String {
//        switch key {
//        case .intranightHR:                 return "heart.circle.fill"
////        case .intranightHRV:                return "waveform.path.ecg"
//        case .intranightRespRate:           return "lungs.fill"
////        case .intranightO2:                 return "drop.fill"
//        case .heartRate, .restingHeartRate: return "heart.fill"
//        case .stepCount:                    return "figure.walk"
//        case .distanceKm:                   return "map"
//        case .activeEnergy:                 return "flame.fill"
//        case .asleepHours:                  return "bed.double.fill"
//        default:                            return "waveform.path.ecg"
//        }
//    }
    
    private func metricTitle(_ key: HealthKitSleepViewModel.MetricKey) -> String {
        switch key {
        case .intranightHR:     return "Heart Rate"
        case .intranightHRV:    return "HRV During Sleep"
        case .intranightRespRate: return "Resp Rate"
        case .intranightO2:     return "O2 Saturation"
        case .heartRate:        return "Avg Heart Rate"
        case .restingHeartRate: return "Avg Resting HR"
        case .stepCount:        return "Steps"
        case .distanceKm:       return "Distance"
        case .activeEnergy:     return "Active Energy"
        case .asleepHours:      return "Sleep Duration"
        default:                return key.label
        }
    }
    
    private func metricIcon(_ key: HealthKitSleepViewModel.MetricKey) -> String {
        switch key {
        case .intranightHR:     return "heart.circle.fill"
        case .intranightHRV:    return "waveform.path.ecg"
        case .intranightRespRate: return "lungs.fill"
        case .intranightO2:     return "drop.fill"
        case .heartRate, .restingHeartRate: return "heart.fill"
        case .stepCount:        return "figure.walk"
        case .distanceKm:       return "map"
        case .activeEnergy:     return "flame.fill"
        case .asleepHours:      return "bed.double.fill"
        default:                return "waveform.path.ecg"
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
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? accentColor : accentColor.opacity(0.6))
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? accentColor.opacity(0.2) : Color.white.opacity(0.08))
            )
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
    let overlayData: [(key: HealthKitSleepViewModel.MetricKey, points: [HealthKitManager.DataPoint], color: Color)]

    // Shared x-domain so bars and line line up in time
    private var xDomain: ClosedRange<Date>? {
        let segDates = segments.flatMap { [$0.start, $0.end] }
        let metricDates = overlayData.flatMap { overlay in
            overlay.points.map { $0.date }
        }
        let all = segDates + metricDates
        guard let minDate = all.min(), let maxDate = all.max() else {
            return nil
        }
        return minDate...maxDate
    }
    
    public func yDomain(for points: [HealthKitManager.DataPoint]) -> ClosedRange<Double> {
        guard !points.isEmpty else { return 0...100 }
        let values = points.map { $0.value }
        let minVal = values.min() ?? 0
        let maxVal = values.max() ?? 100
        let range = maxVal - minVal
        let padding = range * 0.2
        return (minVal - padding)...(maxVal + padding)
    }
    

    @ViewBuilder
        private var sleepBarChart: some View {
            if !segments.isEmpty {
                Chart(segments, id: \.start) { seg in
                    BarMark(
                        xStart: .value("Start", seg.start),
                        xEnd: .value("End", seg.end),
                        y: .value("Stage", 0),
                        height: .fixed(50)
                    )
                    .cornerRadius(4)
                    .foregroundStyle(sleepStageColor(seg.stage).opacity(0.8))
                }
                .chartXScale(domain: xDomain ?? defaultDomain)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(Self.hourFormatter.string(from: date))
                                    .font(.caption2)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYScale(domain: -1...1)
//                .chartYAxis {
//                    // Hide the Y-axis labels for the sleep bar
//                    AxisMarks(position: .leading) { _ in
//                        AxisGridLine().opacity(0)
//                        AxisValueLabel().hidden()
//                    }
//                }
                .chartYAxisLabel(position: .bottom, alignment: .center) {
                    // Placeholder for proper bar placement
                    Rectangle().frame(height: 80).hidden()
                }
                .chartLegend(.hidden)
                .chartPlotStyle { plot in
                    plot.background(.clear)
                }
                .frame(height: 30)
//                .padding(.bottom, 60)
            }
        }

        @ViewBuilder
        private var metricLineCharts: some View {
            if !overlayData.isEmpty {
                ForEach(Array(overlayData.enumerated()), id: \.offset) { index, item in
                    Chart(item.points) { point in
                        LineMark(
                            x: .value("Time", point.date),
                            y: .value("Value", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .foregroundStyle(item.color)
                        .symbol {
                            Circle()
                                .fill(item.color)
                                .frame(width: 5, height: 5)
                        }
                    }
                    .chartXScale(domain: xDomain ?? defaultDomain)
                    .chartXAxis(.hidden) // Hidden to let the sleepBarChart render the main axis
                    .chartYAxis(.hidden) // Hidden, typically you'd show this on the right side if needed
                    .chartYScale(domain: yDomain(for: item.points))
                    .chartPlotStyle { plot in
                        plot.background(.clear)
                    }
                }
            }
        }
        
        // --- Composed Body View ---

//        var body: some View {
//            ZStack(alignment: .bottom) { // Use ZStack with alignment for clearer stacking
//                // BACKGROUND: Single-row sleep bar
//                sleepBarChart
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Ensure it hugs the bottom
//
//                // FOREGROUND: Metric lines
//                metricLineCharts
////                    .padding(.bottom, 55)
//                    .allowsHitTesting(false)
//            }
//        }
    
//    var body: some View {
//        VStack(spacing: 0) {
//            // FOREGROUND: Metric lines (takes up most of the space)
//            ZStack {
//                metricLineCharts
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            
//            // BACKGROUND: Sleep bar at the bottom (below the metric lines)
//            sleepBarChart
//                .frame(height: 50) // Fixed height for sleep bar
//        }
//    }
    
    var body: some View {
        VStack(spacing: 0) {
            // FOREGROUND: Metric lines (no X-axis)
            ZStack {
                if !overlayData.isEmpty {
                    ForEach(Array(overlayData.enumerated()), id: \.offset) { index, item in
                        Chart(item.points) { point in
                            LineMark(
                                x: .value("Time", point.date),
                                y: .value("Value", point.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                            .foregroundStyle(item.color)
                            .symbol {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .chartXScale(domain: xDomain ?? defaultDomain)
                        .chartXAxis(.hidden) // Completely hidden
                        .chartYAxis {
                            AxisMarks(position: index == 0 ? .leading : .trailing) { _ in
                                AxisValueLabel()
                                    .font(.caption2)
                            }
                        }
                        .chartYScale(domain: yDomain(for: item.points))
                        .chartPlotStyle { plot in
                            plot.background(.clear)
                        }
                        .padding(.leading, index == 0 ? 0 : 45)
                        .padding(.trailing, index == 0 ? 45 : 0)
                    }
                }
            }
            .frame(maxWidth: .infinity)
//            .padding(.bottom, 4) // Small gap between charts
            
            // BACKGROUND: Sleep bar with X-axis (this is the ONLY X-axis)
            if !segments.isEmpty {
                Chart(segments, id: \.start) { seg in
                    BarMark(
                        xStart: .value("Start", seg.start),
                        xEnd: .value("End", seg.end),
                        y: .value("Stage", 0),
                        height: .fixed(30)
                    )
                    .cornerRadius(4)
                    .foregroundStyle(sleepStageColor(seg.stage).opacity(0.8))
                }
                .chartXScale(domain: xDomain ?? defaultDomain)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(Self.hourFormatter.string(from: date))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis(.hidden) // Hide Y-axis for sleep bar
                .chartLegend(.hidden)
                .chartPlotStyle { plot in
                    plot.background(.clear)
                }
                .padding(.leading, 25)
                .padding(.trailing, 25)

                .frame(height: 60) // Includes space for X-axis labels
            }
        }
//        .darkGloss()
    }



    private var defaultDomain: ClosedRange<Date> {
        let now = Date()
        let later = Calendar.current.date(byAdding: .hour, value: 8, to: now) ?? now
        return now...later
    }

    private static let hourFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h a"
        return df
    }()
}


