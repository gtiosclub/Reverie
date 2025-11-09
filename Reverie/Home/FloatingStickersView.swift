//
//  FloatingStickersView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/13/25.
//

import SwiftUI

struct FloatingStickersView: View {
//    @Environment(FirebaseDCService.self) private var fbdcs
    @State private var characters: [CardModel] = []
    
    var user = FirebaseLoginService.shared.currUser!



    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(characters) { character in
                    if character.isShown {
                        FloatingStickerIndividualView(
                            character: character,
                            screenSize: geometry.size
                        )
                    }
                }
            }
        }
        .task {
//            do {
            self.characters = user.dreamCards
//            } catch {
//                print("Error fetching characters: \(error.localizedDescription)")
//            }
        }
    }
}
