//
//  DreamCardCharacterInformationView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/30/25.
//

import SwiftUI

struct DreamCardCharacterInformationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isUnlocked = false
    
    // This view takes a single character object
    let character: CardModel
    
    var body: some View {
        ZStack {
            // A semi-transparent background to focus on the card
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture { dismiss() }

            // The Card
            VStack(spacing: 16) {
//                Text("CHARACTER UNLOCKED")
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white.opacity(0.7))
//                    .padding(.top, 20)

                VStack(spacing: 16) {
                    Image(systemName: character.image ?? "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.white)

                    Text(character.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(character.archetype)
                        .font(.headline)
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                
                    Text(character.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxHeight: .infinity, alignment: .center)

                Spacer()
            }
            .frame(width: 320, height: 450)
            .background(
                Circle()
                    .fill(character.cardColor.gradient)
                    .shadow(color: character.cardColor.opacity(0.7), radius: 20, x: 0, y: 0)
                    .shadow(color: character.cardColor.opacity(0.4), radius: 40, x: 0, y: 0)
            )
            .overlay(
                // Close button
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(),
                alignment: .topTrailing
            )
            // Animation for when the card appears
            .rotation3DEffect(.degrees(isUnlocked ? 0 : 90), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(isUnlocked ? 1.0 : 0.5)
            .opacity(isUnlocked ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isUnlocked = true
                }
            }
        }
    }
}
