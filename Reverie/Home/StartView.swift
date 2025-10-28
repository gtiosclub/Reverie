//
//  HomeDCConnectionView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/12/25.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var ts: TabState
    var body: some View {
        NavigationStack{
            ZStack {
                BackgroundView()
                
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        HomeView()
                            .frame(height: UIScreen.main.bounds.height)
                        
                        DreamCardView()
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
}

#Preview {
    StartView()
        .environment(FirebaseLoginService.shared)
        .environmentObject(TabState())
}
