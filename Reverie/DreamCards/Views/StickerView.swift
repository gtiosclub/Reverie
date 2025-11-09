//
//  StickerView.swift
//  Reverie
//
//  Created by Jacoby Melton on 9/30/25.
//

import SwiftUI

struct StickerView: View {
    @Binding var characters: [CardModel] // Binding to allow updates to characters' pinned state
    @Binding var selectedCharacter: CardModel?

    private let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            // Sort characters so pinned ones appear first, then by name
            LazyHGrid(rows: rows, spacing: 25) {
                ForEach(
                    $characters
                        // only pinned characters
                        .filter { $0.wrappedValue.isPinned }
                        .sorted { lhs, rhs in
                            let a = lhs.wrappedValue
                            let b = rhs.wrappedValue
                            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
                        }
                ) { $character in
                    CharacterView(character: $character)
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


struct CharacterView: View {
    @Binding var character: CardModel // Binding to allow toggling of isPinned
    let size: CGFloat
    
    init(character: Binding<CardModel>, size: CGFloat = 110) {
        self._character = character
        self.size = size
    }
//    
//    /// Convenience init for non-editable CardModel
//    init(character: CardModel, size: CGFloat = 90) {
//        self._character = .constant(character)
//        self.size = size
//    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill(LinearGradient(colors: [character.cardColor.swiftUIColor, .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 5)

            Circle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10)

            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white.opacity(0.35), location: 0),
                            .init(color: .clear, location: 0.4)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blendMode(.overlay)

            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
            
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.4),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
                .blur(radius: 1)
                .scaleEffect(0.98)

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
            .frame(width: size, height: size)
            .foregroundColor(.white)

            // Small top-left filled pin indicator (only visible when pinned)
//            if character.isPinned {
//                Image(systemName: "pin.fill")
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundStyle(Color.purple)              // purple-filled as requested
//                    .rotationEffect(.degrees(-45))              // tilt 45° NW
//                    .padding(6)
//                    .background(Circle().fill(.ultraThinMaterial)) // readability over varied wallpapers
//                    .padding(6)                                     // inset from edges
//            }
        }
        .frame(width: size, height: size)
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}


#Preview {
    StickerViewPreviewHost()
}

/// Dedicated preview host so we can use @State for bindings and try different cases.
private struct StickerViewPreviewHost: View {
    @State private var mockCharacters: [CardModel] = {
        var c1 = CardModel(userID: "1", id: "1", name: "Morpheus",
                           description: "Dream shaper", image: nil, cardColor: .blue)
        c1.isPinned = true                                     // pinned
        var c2 = CardModel(userID: "2", id: "2", name: "Luna",
                           description: "Silent guide", image: nil, cardColor: .purple)
        var c3 = CardModel(userID: "3", id: "3", name: "Kairos",
                           description: "Time bender", image: nil, cardColor: .yellow)
        var c4 = CardModel(userID: "4", id: "4", name: "Atlas",
                           description: "Carries your goals", image: nil, cardColor: .green)
        c4.isPinned = true                                     // another pinned
        var c5 = CardModel(userID: "5", id: "5", name: "Aurora",
                           description: "Focus guide", image: nil, cardColor: .pink)
        return [c1, c2, c3, c4, c5]
    }()

    @State private var selectedCharacter: CardModel? = nil

    var body: some View {
        StickerView(characters: $mockCharacters, selectedCharacter: $selectedCharacter)
            .padding()
    }
}

