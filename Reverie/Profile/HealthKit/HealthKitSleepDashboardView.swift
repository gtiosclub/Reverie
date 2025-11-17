
import SwiftUI
import Charts

struct HealthKitSleepDashboardView: View {
    @StateObject private var vm: HealthKitSleepViewModel = HealthKitSleepViewModel()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Top sleep card (graph + compare buttons)
                    SleepGraphsSection(vm: vm)
                        .padding(.top, 8)
                }
            }
        }
        .onAppear { vm.requestAndFetch() }
    }
}

// MARK: - Top Sleep Card (graphs + buttons)

private struct SleepGraphsSection: View {
    @ObservedObject var vm: HealthKitSleepViewModel
    
    @State private var daysBack: Int = 14
    @State private var selectedMetrics: Set<HealthKitSleepViewModel.MetricKey> = [.intranightHR, .intranightRespRate]
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    @State private var showDatePicker = false
    
    private let compareMetrics: [HealthKitSleepViewModel.MetricKey] = [
        .intranightHR,
        .intranightRespRate,
    ]
    
    public var overlayData: [(key: HealthKitSleepViewModel.MetricKey, points: [HealthKitManager.DataPoint], color: Color)] {
        selectedMetrics.compactMap { key in
            guard let points = vm.series[key], !points.isEmpty else { return nil }
            return (key, points, colorForMetric(key))
        }
    }
    
    private func colorForMetric(_ key: HealthKitSleepViewModel.MetricKey) -> Color {
        switch key {
        case .intranightHR:     return Color(red: 1.0, green: 0.27, blue: 0.33)
        case .intranightRespRate: return Color(.indigo)
        case .heartRate:        return Color(red: 1.0, green: 0.4, blue: 0.5)
        case .restingHeartRate: return Color(red: 0.8, green: 0.4, blue: 1.0)
        case .stepCount:        return Color(red: 0.3, green: 0.9, blue: 0.9)
        case .distanceKm:       return Color(red: 0.2, green: 0.7, blue: 1.0)
        case .activeEnergy:     return Color(red: 1.0, green: 0.8, blue: 0.2)
        case .asleepHours:      return Color(red: 0.6, green: 0.5, blue: 1.0)
        default:                return Color.cyan
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            
            
            // REM summary
            Text(remSummaryText)
                .foregroundColor(.white.opacity(0.7))
                .font(.system(size: 14))
                .padding(.horizontal, 20)
                .padding(.top, 10)
            //.padding(.bottom, 4)
            
            // Date pill
            Button(action: {
                showDatePicker = true
            }) {
                HStack(spacing: 0) {
                    Text("Analyze sleep for: ")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 14))
                    /*Image(systemName: "calendar")
                        .foregroundColor(.white)*/
                    Text(previousNightString)
                        .foregroundColor(Color(red: 95/255, green: 85/255, blue: 236/255 ))
                        .font(.system(size: 14, weight: .bold))

                }
                .padding(.horizontal, 20)
                //.padding(.vertical, 8)
                /*.background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
                )*/
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            //.padding(.horizontal,)
            
            
            
            // CHART CARD - All content inside the darkGloss frame
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.indigo)
                            .font(.system(size: 14, weight: .bold))
                            .padding(.trailing, 1)
                        
                        Text("Sleep")
                            .foregroundColor(.indigo)
                            .font(.system(size: 14))
                            .bold()
                        
                        Spacer()
                        
                       
                    }
                    .padding(.top, 6)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 1)
                        .padding(.horizontal, 8)
                        .padding(.top, 6)
                        .padding(.bottom, 4)
                }
                
                if vm.previousNightSegments.isEmpty {
                    Text("Sleep stages will appear here once data loads.")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .frame(height: 260)
                } else {
                    // Chart
                    SleepOverlayChart(
                        segments: vm.previousNightSegments,
                        overlayData: overlayData,
                        dreampredictions: vm.dreamPredictions
                    )
                    .frame(height: 260)
                    
                    // Legend stays inside the card
                    HStack(spacing: 16) {
                        legendDot(color: sleepStageColor("Awake"), label: "Awake")
                        legendDot(color: sleepStageColor("REM"), label: "REM")
                        legendDot(color: sleepStageColor("Core"), label: "Core")
                        legendDot(color: sleepStageColor("Deep"), label: "Deep")
                    }
                }
            }
        
                .padding(16) // Single padding for entire card content
               .darkGloss()
            //}.darkGloss()
            
            
            // COMPARE SECTION (outside the card)
            VStack(alignment: .leading, spacing: 12) {
               
                
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
                }.padding(.horizontal, 20)
            }
            // --- DREAM PREDICTIONS SUMMARY ---
            if !vm.dreamPredictions.isEmpty {
                DreamPredictionSummary(vm: vm)
            }
        }
        .padding(.horizontal, 20) // Single outer padding
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate) {
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
                        in: ...Date(),
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
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
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
private struct DreamPredictionSummary: View {
    @ObservedObject var vm: HealthKitSleepViewModel
    
    private func dreamConfidenceColor(for confidence: Double) -> Color {
        if confidence > 0.7 {
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        } else if confidence > 0.5 {
            return Color(red: 0.93, green: 0.51, blue: 0.93) // Violet
        } else {
            return Color(red: 0.68, green: 0.85, blue: 0.90) // Light blue
        }
    }

    private func formatDreamTime(_ prediction: DreamPrediction) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let start = formatter.string(from: prediction.startTime)
        let end = formatter.string(from: prediction.endTime)
        return "\(start) - \(end)"
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.yellow)
                Text("Predicted Dream Windows")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            ForEach(Array(vm.dreamPredictions.enumerated()), id: \.offset) { index, prediction in
                HStack(spacing: 12) {
                    // Confidence indicator
                    Circle()
                        .fill(dreamConfidenceColor(for: prediction.confidence))
                        .frame(width: 8, height: 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDreamTime(prediction))
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text(prediction.reasoning)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("\(Int(prediction.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.06))
                )

            }
        }
        .padding(16)
        .padding(.top, -10)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color.white.opacity(0.04))
//        )
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
                    //.foregroundColor(.white)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))

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

private struct SleepOverlayChart: View {
    let segments: [HealthKitManager.SleepSegment]
    let overlayData: [(key: HealthKitSleepViewModel.MetricKey, points: [HealthKitManager.DataPoint], color: Color)]
    let dreampredictions: [DreamPrediction]
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
    
    var body: some View {
        VStack(spacing: 0) {
            // METRIC LINES (top section)
            if !overlayData.isEmpty {
                ZStack {
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
                        .chartXAxis(.hidden)
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
                        // Only add padding for the second metric (on the right)
                        .padding(.trailing, index == 1 ? 0 : 40)
                        .padding(.leading, index == 0 ? 0 : 40)
                    }
                }
                .frame(height: 180)
            }
            
            if !dreampredictions.isEmpty {
                GeometryReader { geo in
                         let chartWidth = geo.size.width - 90
                ForEach(Array(dreampredictions.enumerated()), id: \.offset) { index, prediction in
                        // Calculate position based on time
                        if let domain = xDomain {
                            let totalDuration = domain.upperBound.timeIntervalSince(domain.lowerBound)
                            let startOffset = prediction.startTime.timeIntervalSince(domain.lowerBound)
                            let duration = prediction.endTime.timeIntervalSince(prediction.startTime)
                            
                            let xStart = 45 + (CGFloat(startOffset / totalDuration) * chartWidth)
                            let width = CGFloat(duration / totalDuration) * chartWidth
                            
                            // Dream highlight with gradient
                            VStack(spacing: 2) {
                                if width > 50 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "moon.stars.fill")
                                            .font(.caption2)
                                        
                                        if width > 90 {
                                            Text("Dream")
                                                .font(.caption2)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(dreamColor(for: prediction.confidence).opacity(0.3))
                                    )
                                    .foregroundColor(dreamColor(for: prediction.confidence))
                                } else {
                                    Image(systemName: "moon.stars.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(dreamColor(for: prediction.confidence))
                                        .padding(4)
                                        .background(
                                            Circle()
                                                .fill(dreamColor(for: prediction.confidence).opacity(0.3))
                                        )
                                }
                            }
                            .frame(width: max(width, 20))
                            .position(x: xStart + width/2, y: geo.size.height / 4)
                        }
                    }
                    .allowsHitTesting(false)
                }
            }
            
            // SLEEP BAR WITH X-AXIS (bottom section)
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
                .chartYAxis(.hidden)
                .chartLegend(.hidden)
                .chartPlotStyle { plot in
                    plot.background(.clear)
                }
                .frame(height: 60)
                .padding(.top, 8)
            }
        }
    }
    
    private var defaultDomain: ClosedRange<Date> {
        let now = Date()
        let later = Calendar.current.date(byAdding: .hour, value: 8, to: now) ?? now
        return now...later
    }
    
    private func dreamColor(for confidence: Double) -> Color {
        if confidence > 0.7 {
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        } else if confidence > 0.5 {
            return Color(red: 0.93, green: 0.51, blue: 0.93) // Violet
        } else {
            return Color(red: 0.68, green: 0.85, blue: 0.90) // Light blue
        }
    }
    
    private static let hourFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h a"
        return df
    }()
}
