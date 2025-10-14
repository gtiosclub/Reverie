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
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [character.cardColor.swiftUIColor, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 5)

            Circle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10)

//            Image(systemName: character.image ?? "person.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                .foregroundStyle(.white.opacity(0.8))
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
        }
        .frame(width: 105, height: 105)
    }
}

//#Preview {
//    StickerView()
//}
