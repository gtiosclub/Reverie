//
//  StickerView.swift
//  Reverie
//
//  Created by Jacoby Melton on 9/30/25.
//

import SwiftUI

struct StickerView: View {
    let characters: [CardModel]
    @Binding var selectedCharacter: CardModel? // This connects to the @State in DreamCardView

    // Define the grid layout: 3 columns, adaptive size
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(characters) { character in
                    CharacterView(character: character)
                        .onTapGesture {
                            // When a character is tapped, we set the selectedCharacter.
                            // This triggers the .fullScreenCover in the parent view.
                            self.selectedCharacter = character
                        }
                }
            }
            .padding()
        }
        .frame(maxHeight: 300) // Give the scroll view a defined height
    }
}

struct CharacterView: View {
    let character: CardModel

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [character.cardColor.opacity(0.8), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 105, height: 105)
                    .shadow(color: character.cardColor, radius: 5)

                Image(systemName: character.image ?? "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
}

//#Preview {
//    StickerView()
//}
