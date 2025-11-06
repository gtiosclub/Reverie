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
    
    init(characters: Binding<[CardModel]>, selectedCharacter: Binding<CardModel?> = .constant(nil)) {
        self._characters = characters
        self._selectedCharacter = selectedCharacter
    }
    
    
    private let cols: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    func createPages(elements: Binding<[CardModel]>, itemsPerPage: Int) -> [[Binding<CardModel>]] {
        var pages: [[Binding<CardModel>]] = []
        var currentIndex = 0
        while currentIndex < elements.count {
            let endIndex = min(currentIndex + itemsPerPage, elements.count)
            let page = Array(elements[currentIndex..<endIndex])
            pages.append(page)
            currentIndex += itemsPerPage
        }
        return pages
    }
    
    
    var body: some View {
        
        GeometryReader { geo in
            let pages = createPages(elements: $characters, itemsPerPage: 15)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        TabView {
                            ForEach(pages.indices, id: \.self) { pageIndex in
                                VStack {
                                    CharacterGridView(
                                        page: pages[pageIndex],
                                        geoWidth: geo.size.width,
                                        cols: cols
                                    ) { selected in
                                        self.selectedCharacter = selected
                                    }
                                    .padding(.top, 20)
                                    Spacer()
                                }
                            }
                        }
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .tabViewStyle(.page)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    dismiss()
                                }
                            }
                        }

                        if let character = selectedCharacter {
                            DreamCardCharacterInformationView(
                                selectedCharacter: $selectedCharacter,
                                character: character
                            )
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                    removal: .opacity
                                )
                            )
                            .id(character.id)
                        }
                    }
                    .frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct CharacterGridView: View {
    let page: [Binding<CardModel>]
    let geoWidth: CGFloat
    let cols: [GridItem]
    let onSelect: (CardModel) -> Void

    var body: some View {
        LazyVGrid(columns: cols, spacing: 40) {
            ForEach(page.indices, id: \.self) { itemIndex in
                CharacterView(
                    character: page[itemIndex],
                    size: geoWidth / 3 * 0.5
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(page[itemIndex].wrappedValue)
                }
            }
        }
        .padding(10)
        .frame(alignment: .top)
    }
}


//#Preview {
//    @Previewable @State var characters: [CardModel]  = [
//        CardModel(userID: "1", id: "1", name: "Morpheus", description: "Builds the very landscapes of your dreams, weaving reality from thought.", image: "square.stack.3d.up.fill", cardColor: .blue),
//        CardModel(userID: "2", id: "2", name: "Luna", description: "A silent guide who appears in dreams to offer wisdom and direction.", image: "moon.stars.fill", cardColor: .purple),
//        CardModel(userID: "3", id: "3", name: "Phobetor", description: "Embodies your fears, creating nightmares to be confronted.", image: "figure.walk.diamond.fill", cardColor: .yellow),
//        CardModel(userID: "4", id: "4", name: "Hypnos", description: "Spins the threads of slumber, granting rest and peace.", image: "bed.double.fill", cardColor: .pink),
//        CardModel(userID: "5", id: "5", name: "Oneiros", description: "Carries prophetic messages and symbols through the dream world.", image: "envelope.badge.fill", cardColor: .blue),
//        CardModel(userID: "6", id: "6", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "7", id: "7", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "8", id: "8", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "9", id: "9", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "10", id: "10", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "11", id: "11", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "12", id: "12", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "13", id: "13", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "14", id: "14", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "15", id: "15", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "16", id: "16", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "17", id: "17", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "18", id: "18", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "19", id: "19", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "20", id: "20", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green),
//        CardModel(userID: "21", id: "21", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green)
//        
//    ]
//    CharacterArchiveView(characters: $characters)
//}
