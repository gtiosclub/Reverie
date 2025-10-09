//
//  HomeView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Environment(FirebaseLoginService.self) private var fls
    
    @State private var showSecondView = false
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                MoonView()
                VStack {
                    Text("Good Morning, \(fls.currUser?.name ?? "Dreamer")")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)
                    NewLogView()



                }
                .padding(.bottom, 40)
                TabbarView()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Update the drag offset as the user swipes
                    self.dragOffset = value.translation
                }
                .onEnded { value in
                    // Check if it's a significant upward swipe
                    // Negative indicates an upward swipe
                    if value.translation.height < -100 {
                        self.showSecondView = true
                    }
                    // Reset the drag offset
                    self.dragOffset = .zero
                }
        )
        .fullScreenCover(isPresented: $showSecondView) {
            DreamCardView()
        }
    }
}

#Preview {
    HomeView()
//        .environment(FirebaseUserService.shared)
}

