// SleepBrowseView.swift

import SwiftUI
import Foundation

struct SleepBrowseView: View {
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var segments: [HealthKitManager.SleepSegment] = []
    @State private var remMinutes: Int = 0
    @State private var isCalendarPresented = false

    private let hk = HealthKitManager()

    var body: some View {
        VStack(spacing: 18) {
            // Header chip
            HStack {
                Text("BROWSE SLEEP")
                    .font(.caption.weight(.semibold))
                    .kerning(1)
                    .foregroundColor(Theme.accent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.pill.opacity(0.6), in: Capsule())
                Spacer()
            }
            .padding(.top, 8)

            // Main card
            VStack(alignment: .leading, spacing: 14) {

                HStack(spacing: 10) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white.opacity(0.7))
                    Text("Sleep")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                }

                Text(remSummaryText)
                    .foregroundColor(.white.opacity(0.85))
                    .font(.subheadline)

                Button { isCalendarPresented = true } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(formattedDate(selectedDate))
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Theme.pill, in: RoundedRectangle(cornerRadius: 12))
                }

                HypnogramChart(segments: segments)
                    .frame(height: 150)
                    .background(Theme.cardHi, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.gridLine, lineWidth: 1)
                    )

                StageLegend()

                Text("Compare to")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.subheadline)
                    .padding(.top, 6)

                CompareChips()
            }
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.gridLine, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 18, y: 10)

            BottomTabBar()
        }
        .sheet(isPresented: $isCalendarPresented) {
            DatePickerSheet(selectedDate: $selectedDate)
                .presentationDetents([.medium])
        }
        .onAppear {
            requestHealthKitAndLoad()
        }
        .onChange(of: selectedDate) { newDate in
            load(for: newDate)
        }
    }

    // MARK: - Summary text

    private var remSummaryText: AttributedString {
        let mins = max(remMinutes, 0)
        let h = mins / 60
        let m = mins % 60

        var base = AttributedString("You spent ")
        var bold = AttributedString("\(h) hours and \(m) minutes")
        bold.font = .system(.subheadline, design: .rounded).weight(.semibold)
        base.append(bold)
        base.append(AttributedString(" in REM sleep last night."))
        return base
    }

    // MARK: - HealthKit

    private func requestHealthKitAndLoad() {
        #if targetEnvironment(simulator)
        load(for: selectedDate)
        #else
        hk.requestAuthorization { success, error in
            if !success {
                print("HealthKit auth failed:", error?.localizedDescription ?? "Unknown")
                return
            }
            DispatchQueue.main.async {
                load(for: selectedDate)
            }
        }
        #endif
    }

    private func load(for day: Date) {
        #if targetEnvironment(simulator)
        let segs = SleepMocks.makeSegments(for: day)
        self.segments = segs
        self.remMinutes = Self.remMinutes(from: segs)
        #else
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        let end   = cal.date(byAdding: .day, value: 1, to: start)!

        hk.fetchSleepSegments(start: start,
                              end: end,
                              onlyAppleHealthSource: true) { segs in
            self.segments = segs
            self.remMinutes = Self.remMinutes(from: segs)
        }
        #endif
    }

    private static func remMinutes(from segments: [HealthKitManager.SleepSegment]) -> Int {
        let seconds = segments
            .filter { $0.stage == "REM" }
            .reduce(0.0) { $0 + $1.end.timeIntervalSince($1.start) }
        return Int(seconds / 60.0)
    }

    private func formattedDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: d)
    }
}

// MARK: - Hypnogram chart

struct HypnogramChart: View {
    let segments: [HealthKitManager.SleepSegment]

    private func color(for stage: String) -> Color {
        switch stage {
        case "Awake":           return Theme.awake
        case "REM":             return Theme.rem
        case "Deep":            return Theme.deep
        case "Core", "Asleep":  return Theme.light
        case "In Bed":          return .white.opacity(0.08)
        default:                return .gray.opacity(0.35)
        }
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let start = segments.first?.start ?? Date()
            let end   = segments.last?.end ?? Date()
            let total = max(end.timeIntervalSince(start), 1)

            ZStack {
                // grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .fill(Theme.gridLine)
                            .frame(height: 1)
                        Spacer()
                    }
                }
                .padding(.vertical, 10)

                HStack(spacing: 4) {
                    ForEach(segments.indices, id: \.self) { i in
                        let s = segments[i]
                        let w = max(6, width * s.end.timeIntervalSince(s.start) / total)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color(for: s.stage))
                            .frame(width: w, height: 110)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 18)
            }
        }
    }
}

// MARK: - Legend & chips

struct StageLegend: View {
    var body: some View {
        HStack(spacing: 10) {
            LegendPill(color: Theme.awake, text: "AWAKE")
            LegendPill(color: Theme.rem,   text: "REM")
            LegendPill(color: Theme.light, text: "LIGHT SLEEP")
            LegendPill(color: Theme.deep,  text: "DEEP SLEEP")
            Spacer()
        }
        .padding(.top, 4)
    }
}

struct LegendPill: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(text)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.05), in: Capsule())
    }
}

struct CompareChips: View {
    private let items = [
        "Heart Rate","Noise","Blood Pressure",
        "Movement","Temperature","Blood Glucose"
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(items, id: \.self) { t in
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill").opacity(0.7)
                    Text(t).font(.subheadline.weight(.medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Theme.pill, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.gridLine, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Bottom tab bar

struct BottomTabBar: View {
    var body: some View {
        HStack {
            TabItem(icon: "house.fill", text: "Home")
            Spacer()
            TabItem(icon: "archivebox.fill", text: "Archive")
            Spacer()
            TabItem(icon: "chart.bar.fill", text: "Analysis", active: true)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(Theme.card)
        .overlay(
            Rectangle()
                .fill(Theme.gridLine)
                .frame(height: 1),
            alignment: .top
        )
    }
}

struct TabItem: View {
    let icon: String
    let text: String
    var active: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(active ? Theme.accent : .white.opacity(0.7))
            Text(text)
                .font(.caption2.weight(.semibold))
                .foregroundColor(active ? Theme.accent : .white.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(active ? Color.white.opacity(0.05) : .clear,
                    in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Date picker + mock segments

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Theme.accent)
                    .padding()
                Spacer()
            }
            .navigationTitle("Select Date")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

enum SleepMocks {
    static func makeSegments(for day: Date) -> [HealthKitManager.SleepSegment] {
        let cal = Calendar.current
        let start = cal.date(bySettingHour: 23, minute: 0, second: 0,
                             of: day.addingTimeInterval(-86400))!
        var t = start
        var out: [HealthKitManager.SleepSegment] = []

        func push(_ mins: Int, _ stage: String) {
            let end = t.addingTimeInterval(Double(mins) * 60)
            out.append(.init(start: t,
                             end: end,
                             hours: Double(mins)/60.0,
                             stage: stage,
                             rawValue: 0,
                             sourceBundleID: "mock"))
            t = end
        }

        push(20,"Awake"); push(70,"Core"); push(25,"REM"); push(60,"Deep")
        push(45,"Core");  push(30,"REM"); push(55,"Core"); push(30,"Deep")
        push(15,"Awake"); push(30,"REM")
        return out
    }
}
