//
//  ReverieApp.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/2/25.
//


import SwiftUI
import Firebase

// MARK: - App Delegate (Firebase)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Main App
@main
struct ReverieApp: App {
    @StateObject private var tabState = TabState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Shared Siri → App Router
    @StateObject private var router = DreamRouter.shared

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AuthRoutingView()
                    // Navigation triggered by DreamRouter
                    .navigationDestination(isPresented: $router.navigateToLog) {
                        LoggingView(initialText: router.injectedDreamText)
                    }
            }
            .environmentObject(tabState)
            .onChange(of: scenePhase) { phase in
                // When app becomes active after Siri interaction
                if phase == .active {
                    handlePendingDreamIfNeeded()
                }
            }
        }
    }

    // MARK: - Handle Dream from Siri
    private func handlePendingDreamIfNeeded() {
        print("🔎 Checking for pending dream…")

        guard let text = router.pendingDreamText, !text.isEmpty else {
            print("⛔️ No pending dream found.")
            return
        }

        print("✨ Pending dream detected: \(text)")
        print("📬 Telling DreamRouter to navigate to logging view.")
        router.navigateToLoggingView(with: text)

        router.pendingDreamText = nil
        print("🧹 Cleared pendingDreamText")
    }
}


//@main
//struct ReverieApp: App {
//    @StateObject private var tabState = TabState()
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @State private var linkActive = false
//
//    @AppStorage("pendingRoute", store: UserDefaults(suiteName: "group.reverie"))
//    private var pendingRoute: String = ""
//
//    var body: some Scene {
//        WindowGroup {
//            AuthRoutingView()
//                .onOpenURL { url in
//                    print("🔗 OPENED URL:", url.absoluteString )
//                    linkActive = true
//                }
//                .navigationDestination(isPresented: $linkActive) {
//                    LoggingView()
//                }
//                .environmentObject(tabState)
//        }
//    }
//}
