import SwiftUI

struct ContentView: View {
    @StateObject private var hkManager = HealthKitViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // GRAPHS FIRST
                    GroupBox {
                        GraphsView(vm: hkManager)
                            .frame(minHeight: 380)
                    }
                    .padding(.horizontal)

                    // METRICS BELOW
                    VStack(spacing: 24) {
                        MetricSection(title: "Health Metrics") {
                            MetricRow(label: "Heart Rate (bpm)", value: hkManager.heartRate)
                            MetricRow(label: "Resting HR (bpm)", value: hkManager.restingHeartRate)
                            MetricRow(label: "Steps", value: hkManager.stepCount)
                            MetricRow(label: "Distance (km)", value: hkManager.distanceWalkingRunning)
                            MetricRow(label: "Active Energy (kcal)", value: hkManager.activeEnergy)
                        }

                        MetricSection(title: "Sleep — Previous Night") {
                            MetricRow(label: "Asleep (hrs)", value: hkManager.sleepDuration)
                            MetricRow(label: "In Bed (hrs)", value: hkManager.inBedTime)
                            MetricRow(label: "REM (hrs)", value: hkManager.remHours)
                            MetricRow(label: "Deep (hrs)", value: hkManager.deepHours)
                            MetricRow(label: "Core (hrs)", value: hkManager.coreHours)
                            MetricRow(label: "Awakenings", value: hkManager.awakenings)
                            MetricRow(label: "Total (hrs)", value: hkManager.totalSleepHours)
                        }

                        MetricSection(title: "Sleep-related Signals") {
                            MetricRow(label: "Respiratory Rate (min⁻¹)", value: hkManager.respiratoryRate)
                            MetricRow(label: "Oxygen Saturation", value: hkManager.oxygenSaturation)
                            MetricRow(label: "HRV SDNN (ms)", value: hkManager.hrv)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Health Dashboard")
            .refreshable { hkManager.requestAndFetch() }
            .onAppear { if !PreviewEnv.isPreview { hkManager.requestAndFetch() } }
        }
    }
}

// Helpers
private struct MetricSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            VStack(spacing: 8) { content }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct MetricRow: View {
    var label: String
    var value: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundColor(.blue).monospacedDigit()
        }
    }
}

#Preview { ContentView() }
