import SwiftUI

struct SleepMetricsApp: App {
    @StateObject private var vm = HealthKitViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .onAppear {
                    #if targetEnvironment(simulator)
                    vm.loadMockForPreview()
                    #else
                    vm.requestAndFetch()   // 🔥 Real HealthKit load on device
                    #endif
                }
        }
    }
}
