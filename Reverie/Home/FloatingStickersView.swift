//
//  FloatingStickersView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/13/25.
//

import SwiftUI

struct FloatingStickersView: View {
    @Environment(FirebaseDCService.self) private var fbdcs
    @State private var characters: [CardModel] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(characters) { character in
                    FloatingStickerIndividualView(
                        character: character,
                        screenSize: geometry.size
                    )
                }
            }
        }
        .task {
            do {
                self.characters = try await fbdcs.fetchDCCards()
            } catch {
                print("Error fetching characters: \(error.localizedDescription)")
            }
        }
    }
}
