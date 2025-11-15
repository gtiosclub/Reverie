// ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: HealthKitViewModel

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 20) {
                // Night-level hypnogram card
                SleepBrowseView()

                // 14-day analysis graph
                GraphsView(vm: vm)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitViewModel())
}
