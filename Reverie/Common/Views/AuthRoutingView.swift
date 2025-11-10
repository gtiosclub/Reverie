//
//  AuthRoutingView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/28/25.
//

import SwiftUI
import Observation

struct AuthRoutingView: View {
//    @Environment(FirebaseLoginService.self) private var fls
//    @Environment(FirebaseUserService.self) private var fus
//    @Environment(FirebaseDreamService.self) private var fds
//    @Environment(FirebaseDCService.self) private var fbdcs

    var body: some View {
        NavigationStack {
            if FirebaseLoginService.shared.currUser != nil {
                StartView()
//                    .environment(FirebaseLoginService.shared)
            } else {
                LoginView()
            }
        }
    }
}
