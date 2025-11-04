//
//  CharacterArchiveView.swift
//  Reverie
//
//  Created by Jacoby Melton on 10/28/25.
//

import SwiftUI

struct CharacterArchiveView: View {
    @Binding var characters: [CardModel] // Binding to allow updates to characters' pinned state
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCharacter: CardModel?
    
    private let cols: [GridItem] = Array(repeating: .init(.flexible()), count: 5)

    var body: some View {
        GeometryReader { geo in
            ZStack {
//                BackgroundView()
                Color.black.opacity(0.85).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedCharacter = nil
                        }
                    }
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black)

                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: cols, spacing: 15) {
                        ForEach($characters) { $character in
                            CharacterView(character: $character, size: geo.size.width / 5 * 0.7)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selectedCharacter = character
                                }
                        }
//                        { character in
//                            CharacterView(character: character, size: geo.size.width / 5 * 0.7)
                        
                    }
                }
                .padding(10)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                
                if let character = selectedCharacter {
                    DreamCardCharacterInformationView(
                        selectedCharacter: $selectedCharacter, character: character
                    )
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.8)), removal: .opacity))
                    .id(character.id)
                }
                    
                
            }
            .frame(width: .infinity, height: geo.size.height * 0.75, alignment: .center)
            
        }
    }
}

//#Preview {
//    CharacterArchiveView(characters: [
//                CardModel(userID: "1", id: "1", name: "Morpheus", description: "Builds the very landscapes of your dreams, weaving reality from thought.", image: "square.stack.3d.up.fill", cardColor: .blue),
//                CardModel(userID: "2", id: "2", name: "Luna", description: "A silent guide who appears in dreams to offer wisdom and direction.", image: "moon.stars.fill", cardColor: .purple),
//                CardModel(userID: "3", id: "3", name: "Phobetor", description: "Embodies your fears, creating nightmares to be confronted.", image: "figure.walk.diamond.fill", cardColor: .yellow),
//                CardModel(userID: "4", id: "4", name: "Hypnos", description: "Spins the threads of slumber, granting rest and peace.", image: "bed.double.fill", cardColor: .pink),
//                CardModel(userID: "5", id: "5", name: "Oneiros", description: "Carries prophetic messages and symbols through the dream world.", image: "envelope.badge.fill", cardColor: .blue),
//                CardModel(userID: "6", id: "6", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green)
//                
//            ])
//}
