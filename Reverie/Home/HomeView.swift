//
//  HomeView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct HomeView: View {
    let user = UserModel.init(name: "Brayden")
    @State private var showSecondView = false
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack {
                    Text("Good Morning, \(user.name)")
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
                    // When the swipe ends, check if it's a significant upward swipe
                    // A negative vertical translation indicates an upward swipe
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
}
