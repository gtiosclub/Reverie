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

    var body: some Scene {
        WindowGroup {
            AuthRoutingView()
                .environment(FirebaseLoginService.shared)
                .environment(FirebaseDreamService.shared)
                .environment(FirebaseDCService.shared)
        }
    }
}
