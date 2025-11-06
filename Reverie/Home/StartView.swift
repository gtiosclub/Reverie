//
//  HomeDCConnectionView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/12/25.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var ts: TabState
    @State var isOnHomeScreen = false
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    HomeView()
                        .frame(height: UIScreen.main.bounds.height)
                    
                    DreamCardView(isOnHomeScreen: $isOnHomeScreen)
                        .frame(height: UIScreen.main.bounds.height)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                TabbarView()
            }
        }
        .onAppear {
            ts.activeTab = .home
        }
    }
}

#Preview {
    StartView()
        .environment(FirebaseLoginService.shared)
        .environmentObject(TabState())
}
