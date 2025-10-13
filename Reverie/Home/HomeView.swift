//
//  HomeView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Environment(FirebaseUserService.self) private var fus
    
    var body: some View {
        ZStack {
            MoonView()
            FloatingStickersView()
            
            VStack {
                Text("Good Morning, \(fus.currentUser?.displayName ?? "Dreamer")")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                NewLogView()
            }
            .padding(.bottom, 30)
        }
        .background(.clear)
    }
}

#Preview {
    HomeView()
        .environment(FirebaseUserService.shared)
}
