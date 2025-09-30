//
//  ProfileView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                Text("reverie profile")
                NavigationLink(destination: TestView()) {
                    Text("Test Page")
                }
            }
            TabbarView()
        }
    }
}

#Preview {
    ProfileView()
}
