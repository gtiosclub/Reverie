//
//  DreamCardView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/23/25.
//

import SwiftUI

struct DreamCardView: View {
    @State private var characters: [CardModel] = [
        // ... (your character data remains the same)
        CardModel(name: "Morpheus", archetype: "The Architect", description: "Builds the very landscapes of your dreams, weaving reality from thought.", image: "square.stack.3d.up.fill", cardColor: .blue),
        CardModel(name: "Luna", archetype: "The Guide", description: "A silent guide who appears in dreams to offer wisdom and direction.", image: "moon.stars.fill", cardColor: .purple),
        CardModel(name: "Phobetor", archetype: "The Shapeshifter", description: "Embodies your fears, creating nightmares to be confronted.", image: "figure.walk.diamond.fill", cardColor: .red),
        CardModel(name: "Hypnos", archetype: "The Weaver", description: "Spins the threads of slumber, granting rest and peace.", image: "bed.double.fill", cardColor: .teal),
        CardModel(name: "Oneiros", archetype: "The Messenger", description: "Carries prophetic messages and symbols through the dream world.", image: "envelope.badge.fill", cardColor: .orange),
        CardModel(name: "Kairos", archetype: "The Trickster", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green)
    ]
    
    @State private var selectedCharacter: CardModel?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack(spacing: 30) {
                    StickerView(characters: characters, selectedCharacter: $selectedCharacter)
                    
                    Spacer()
                    
                    Text("Future Card Pack Area")
                        .foregroundStyle(.gray)
                        .padding()
                        .border(Color.gray, width: 1)

                    Spacer()
                }
                .padding(.top, 40)

                if let character = selectedCharacter {
                    DreamCardCharacterInformationView(character: character)
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.8)), removal: .opacity))
                }
            }
        }
    }
}

#Preview {
    DreamCardView()
}
