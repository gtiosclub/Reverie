//
//  DreamCardView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/23/25.
//

import SwiftUI

struct DreamCardView: View {
//    @Environment(FirebaseDreamService.self) private var fbds
//    @Environment(FirebaseDCService.self) private var fbdcs
    
//    @State private var characters: [CardModel] = [
//        CardModel(userID: "1", id: "1", name: "Morpheus", description: "Builds the very landscapes of your dreams, weaving reality from thought.", image: "square.stack.3d.up.fill", cardColor: .blue),
//        CardModel(userID: "2", id: "2", name: "Luna", description: "A silent guide who appears in dreams to offer wisdom and direction.", image: "moon.stars.fill", cardColor: .purple),
//        CardModel(userID: "3", id: "3", name: "Phobetor", description: "Embodies your fears, creating nightmares to be confronted.", image: "figure.walk.diamond.fill", cardColor: .yellow),
//        CardModel(userID: "4", id: "4", name: "Hypnos", description: "Spins the threads of slumber, granting rest and peace.", image: "bed.double.fill", cardColor: .pink),
//        CardModel(userID: "5", id: "5", name: "Oneiros", description: "Carries prophetic messages and symbols through the dream world.", image: "envelope.badge.fill", cardColor: .blue),
//        CardModel(userID: "6", id: "6", name: "Kairos", description: "Bends the rules of time and logic within the dream state.", image: "hourglass", cardColor: .green)
//    ]
    @Binding var isOnHomeScreen: Bool
    
    @State private var characters: [CardModel] = []
    
    @State private var lockedCharacters: [CardModel] = []
    
    @State private var selectedCharacter: CardModel?
    
    @State private var dreamCount: Int = 0
    
    @State private var unlockCards: Bool = false
    
//    @State private var degrees: Double = 8.0
    var progress: Float {
        return Float((dreamCount - 1) % 4 + 1) / 4.0
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
//                StickerView(characters: characters, selectedCharacter: $selectedCharacter)
                HStack {
                    Text("My Characters")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 100)
                
                StickerView(characters: characters, selectedCharacter: $selectedCharacter)
                    .padding(.top, 50)
                
                Spacer()
                
                Text("Unlock in 3 days")
                    .font(.headline.bold())
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                DreamCardProgressView(progress: progress)
                    .scaleEffect(1.5)
                    .padding(.top, 30)
//                    .rotationEffect(.degrees(degrees))
//                    .onAppear {
//                        withAnimation(.linear(duration: 0.12).repeatCount(6, autoreverses: true)) {
//                            degrees = -degrees
//                        }
//                    }
                    .onTapGesture {
                        // opens cards when tapped
                        withAnimation(.spring()) {
                            self.unlockCards = true
                        }
                    }
                    .task {
                        do {
                            let dreams = try await FirebaseDreamService.shared.getDreams()
                            self.dreamCount = dreams.count
                        } catch {
                            print("Error fetching dreams: \(error)")
                        }
                    }
            }
            .padding(.top, 20)
            .padding(.bottom, 120)
            .task {
                do {
                    self.characters = try await FirebaseDCService.shared.fetchDCCards()
                    self.lockedCharacters = characters.filter { !$0.isUnlocked }
                } catch {
                    print("Error fetching cards: \(error.localizedDescription)")
                }
            }
            .onChange(of: unlockCards) {
                if unlockCards == false {
                    Task {
                        self.characters = try await FirebaseDCService.shared.fetchDCCards()
                        self.lockedCharacters = characters.filter { !$0.isUnlocked }
                    }
                }
            }
            
            if let character = selectedCharacter {
                DreamCardCharacterInformationView(selectedCharacter: $selectedCharacter, character: character, isOnHomeScreen: $isOnHomeScreen)
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.8)), removal: .opacity))
                    .id(character.id)
            }
            
            if unlockCards {
                CardUnlockView(unlockCards: $unlockCards, cards: lockedCharacters)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .background(.clear)
    }
}

#Preview {
    DreamCardView(isOnHomeScreen: .constant(false))
}
