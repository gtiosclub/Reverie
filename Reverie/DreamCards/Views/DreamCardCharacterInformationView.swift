//
//  DreamCardCharacterInformationView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/30/25.
//

import SwiftUI

struct DreamCardCharacterInformationView: View {
    @Binding var selectedCharacter: CardModel?
        
    @State private var isUnlocked = false
    let character: CardModel
    
    @Binding var isOnHomeScreen: Bool
    
    var body: some View {
        ZStack {
            // A semi-transparent background to focus on the card
            Color.black.opacity(0.8).ignoresSafeArea()
                .onTapGesture {
                    // When tapped, set the binding to nil to dismiss
                    withAnimation(.spring()) {
                        selectedCharacter = nil
                    }
                }

            // The Card
            VStack(spacing: 16) {

                VStack(spacing: 16) {
//                    Image(systemName: character.image ?? "person.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 90, height: 90)
//                        .foregroundColor(.white)
                    AsyncImage(url: URL(string: character.image ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            Image(systemName: "photo.fill")
                                .foregroundColor(.white.opacity(0.8))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 90, height: 90)
                    .foregroundColor(.white)

                    Text(character.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                
                    Text(character.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    HStack{
                        Toggle(isOn: $isOnHomeScreen) {
                                    Text("Home Screen").foregroundColor(.white)
                                }
                                .padding(50)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)

                Spacer()
            }
            .frame(width: 320, height: 450)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(character.cardColor.swiftUIColor.gradient.opacity(0.5))
                    .shadow(color: character.cardColor.swiftUIColor.opacity(0.7), radius: 20, x: 0, y: 0)
                    .shadow(color: character.cardColor.swiftUIColor.opacity(0.4), radius: 40, x: 0, y: 0)
            )
            .overlay(
                // Close button
                Button(action: {
                    withAnimation(.spring()) {
                        selectedCharacter = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(),
                alignment: .topTrailing
            )
            // Animation for when the card appears
            .rotation3DEffect(.degrees(isUnlocked ? 0 : 120), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(isUnlocked ? 1.0 : 0.5)
            .opacity(isUnlocked ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    isUnlocked = true
                }
            }
        }
    }
}

#Preview {
    DreamCardCharacterInformationView(
        selectedCharacter: .constant(nil),
        character: CardModel(userID: "1", id: "1", name: "Morpheus", description: "Builds the very landscapes of your dreams, weaving reality from thought.", image: "square.stack.3d.up.fill", cardColor: .blue), isOnHomeScreen: .constant(true)
    )
}
