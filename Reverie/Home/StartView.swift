//
//  HomeDCConnectionView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/12/25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                ZStack {
                    BackgroundView()
                    
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 80) {
                            HomeView()
                                .frame(height: geometry.size.height)
                            
                            DreamCardView()
                                .frame(height: geometry.size.height)
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
            }
        }
    }
}

#Preview {
    StartView()
        .environment(FirebaseUserService.shared)
}
