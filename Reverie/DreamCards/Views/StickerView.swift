//
//  StickerView.swift
//  Reverie
//
//  Created by Jacoby Melton on 9/30/25.
//

import SwiftUI

import SwiftUI

import SwiftUI

struct StickerView: View {
    let characters: [CardModel]
    @Binding var selectedCharacter: CardModel?

    private let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 25) {
                ForEach(characters) { character in
                    CharacterView(character: character)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedCharacter = character
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 250)
    }
}

import SwiftUI

struct CharacterView: View {
    let character: CardModel

    var body: some View {
        // The outer VStack was removed to simplify the view hierarchy.
        ZStack {
            // Background glow
            Circle()
                .fill(LinearGradient(colors: [character.cardColor.swiftUIColor, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 5)

            // Frosted glass layer
            Circle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10)

            // Icon on top
            Image(systemName: character.image ?? "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(width: 105, height: 105)
    }
}

//#Preview {
//    StickerView()
//}
