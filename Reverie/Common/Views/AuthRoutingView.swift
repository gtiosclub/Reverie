//
//  AuthRoutingView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/28/25.
//

import SwiftUI
import Observation

struct AuthRoutingView: View {
    @Environment(FirebaseLoginService.self) private var fbls
    @Environment(FirebaseUserService.self) private var fus

    var body: some View {
        if fus.currentUser != nil {
            HomeView()
        } else {
            LoginView()
        }
    }
}
