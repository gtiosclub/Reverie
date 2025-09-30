//
//  DreamCardView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/23/25.
//

import SwiftUI

struct DreamCardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isUnlocked = false
    
    var characterName: String = "Morpheus"
    var archetype: String = "The Architect"
    var description: String = "Builds the landscapes of your dreams."
    var footerText: String = "Swipe to reveal the next insight"
    var cardColor: Color = Color.blue
    
    var body: some View {
        ZStack {
            BackgroundView()
            // Background Dim
            Color.black.opacity(0.4).ignoresSafeArea()
            // Card
            VStack(spacing: 16) {
                Text("CHARACTER UNLOCKED")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 10)
                
                VStack(spacing: 16) {
                    
                
                Image(systemName: "square.stack.3d.up.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .foregroundColor(.white)
                //Character Name
                Text(characterName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                //Headline
                Text(archetype)
                                    .font(.subheadline)
                                    .italic()
                                    .foregroundColor(.white.opacity(0.9))
                // Description
                Text(description)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.85))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: .infinity, alignment: .center) // keeps this chunk centered in our card
                
                Spacer()
                
                Text(footerText)
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.bottom, 10)
            }
            .frame(width: 300, height: 420)
                        .background(RoundedRectangle(cornerRadius: 30)
                            .fill(cardColor)
                            // Glowing effect around the card
                            .shadow(color: cardColor.opacity(0.7), radius: 20, x: 0, y: 0)
                            .shadow(color: cardColor.opacity(0.4), radius: 40, x: 0, y: 0)
                    )
            //Trying to see if the 3D animation
                        .rotation3DEffect(.degrees(isUnlocked ? 0 : 720),
                                          axis: (x: 0, y: 1, z: 0)
                                      ).scaleEffect(isUnlocked ? 1.0 : 0.1)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.5)) {
                        isUnlocked = true
                    }
                }
            
            
            
            TabbarView()
        }
    }
}
/*
VStack {
    Text("Dream Cards")
        .foregroundStyle(Color(.white))
    Button {
        dismiss()
    } label: {
        Image(systemName: "xmark.circle.fill")
            .font(.largeTitle)
            .foregroundColor(.gray)
            .padding()
    }
}*/

#Preview {
    DreamCardView(
        characterName: "Morpheus",
        archetype: "The Architect",
        description: "Builds the landscapes of your dreams."
    )
}
