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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var linkActive = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AuthRoutingView()
                    .environment(FirebaseLoginService.shared)
                    .environment(FirebaseDreamService.shared)
                    .onOpenURL { url in
                        linkActive = true
                    }
                    .navigationDestination(isPresented: $linkActive) {
                        LoggingView()
                    }
            }
        }
    }
}
