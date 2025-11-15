//
//  ReverieApp.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/2/25.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
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

@main
struct ReverieApp: App {
    @StateObject private var tabState = TabState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("pendingRoute", store: UserDefaults(suiteName: "group.reverie"))
    private var pendingRoute: String = ""
    
    @State private var openLogging = false   // << controls navigation

    // NEW: access DreamRouter (for Siri text)
    @StateObject private var router = DreamRouter.shared

    // NEW: store the text that will go into LoggingView
    @State private var loggingInitialText: String = ""

    // NEW: watch scene phase so we know when app becomes active after Siri
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AuthRoutingView()
                    .onOpenURL { url in
                        print("Received URL:", url)

                        // ALWAYS open logging
                        openLogging = true
                    }
                    .navigationDestination(isPresented: $openLogging) {
                        // pass prefilled text when coming from Siri
                        LoggingView(initialText: loggingInitialText)
                    }
            }
            .environmentObject(tabState)
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    handlePendingDream()
                }
            }
        }
    }

    // NEW: read text from DreamRouter (set by the App Intent) and open LoggingView
    private func handlePendingDream() {
        guard let text = router.pendingDreamText, !text.isEmpty else { return }
        loggingInitialText = text
        openLogging = true
        router.pendingDreamText = nil
    }
}

