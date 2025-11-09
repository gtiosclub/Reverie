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
//    @Binding var isOnHomeScreen: Bool
//    
//    @State private var characters: [CardModel] = []
//    
//    @State private var achievements: [CardModel] = []
//    
//    @State private var lockedCharacters: [CardModel] = []
//    
//    @State private var selectedCharacter: CardModel?
    
    @Binding var isOnHomeScreen: Bool
    
    @Binding var characters: [CardModel]
    
    @Binding var lockedCharacters: [CardModel]
    
    @Binding var selectedCharacter: CardModel?
    
    @Binding var unlockCards: Bool
    
    @State private var dreamCount: Int = 0
    
    @State private var showArchive = false
    
    var user = FirebaseLoginService.shared.currUser!
    
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
                    Spacer()
                    Button(action: {
                        showArchive = true
                    }) {
                        Text("View All")
                            .font(.body.bold())
                            .foregroundColor(.indigo)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 100)
                
                StickerView(characters: $characters, selectedCharacter: $selectedCharacter)
                    .padding(.top, 10)
                
                Spacer()
                
                Text("Log \(Int(max(0, 4 - progress))) more dreams to unlock")
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
//                        do {
//                            let dreams = try await FirebaseDreamService.shared.getDreams()
                            self.dreamCount = user.dreams.count
//                        } catch {
//                            print("Error fetching dreams: \(error)")
//                        }
                    }
            }
//            .sheet(isPresented: $showArchive) {
//                CharacterArchiveView(characters: $characters, selectedCharacter: $selectedCharacter)
//            }
            .padding(.bottom, 120)
            
            if showArchive {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showArchive = false
                        }
                    }
                
                CharacterArchiveView(
                    characters: $characters,
                    selectedCharacter: $selectedCharacter,
                    showArchive: $showArchive
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(.clear)
    }
}

//#Preview {
//    DreamCardView(isOnHomeScreen: .constant(false))
//}
