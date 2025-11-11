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

@main
struct ReverieApp: App {
    @StateObject private var tabState = TabState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var linkActive = false
    
    @AppStorage("pendingRoute", store: UserDefaults(suiteName: "group.reverie"))
    private var pendingRoute: String = ""

    var body: some Scene {
        WindowGroup {
            AuthRoutingView()
                .onOpenURL { url in
                    linkActive = true
                }
                .navigationDestination(isPresented: $linkActive) {
                    LoggingView()
                }
                .environmentObject(tabState)
        }
    }
}
