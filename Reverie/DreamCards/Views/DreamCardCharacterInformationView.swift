//
//  DreamCardCharacterInformationView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/30/25.
//

import SwiftUI

struct DreamCardCharacterInformationView: View {
    @Binding var selectedCharacter: CardModel?
    let character: CardModel
    @State private var isUnlocked = false
//    var user = FirebaseLoginService.shared.currUser!
//    @State private var isShownOnHome: Bool
//    @State private var isPinned: Bool
    
    init(selectedCharacter: Binding<CardModel?>,
         character: CardModel) {
        
        self._selectedCharacter = selectedCharacter
        self.character = character
//        self._isPinned = State(initialValue: character.isPinned)
//        self._isShownOnHome = State(initialValue: character.isShown)
    }

    var body: some View {
        ZStack {
//            Rectangle()
////                .fill(.ultraThinMaterial)
//                .blur(radius: 3)
//                .ignoresSafeArea()
//                .onTapGesture {
//                    withAnimation(.spring()) {
//                        selectedCharacter = nil
//                    }
//                }
            
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedCharacter = nil
                    }
                }
            
            // The Card
            VStack(spacing: 16) {
                
                VStack(spacing: 16) {
                    AsyncImage(url: URL(string: character.image ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().tint(.white)
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .failure:
                            Image(systemName: "globe.americas.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white.opacity(0.8))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.top, 60)
                    .frame(width: 150, height: 150)
                    .foregroundColor(.white)
                    
                    Text(character.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(character.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer() // pushes content up
                    
//                    Toggle(isOn: $isShownOnHome) {
//                        EmptyView()
//                    }
//                    .onChange(of: isShownOnHome) { _, newValue in
//                        Task {
//                            await FirebaseUpdateCardService.shared.setIsShown(card: character, isShown: newValue)
//                        }
//                    }
//                    .padding(.horizontal, 160)
//                    .tint(.purple)
//                    .padding(.bottom, 20)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(width: 320, height: 520)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(character.cardColor.swiftUIColor.opacity(0.6), lineWidth: 3)
            )
//            .background(.ultraThinMaterial)
//                .glassEffect(in: .rect(cornerRadius: 20.0))
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.85))
                }
            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//            .shadow(color: character.cardColor.swiftUIColor.opacity(0.6), radius: 12, x: 0, y: 4)
            .overlay(
                // Back Button
                Button(action: {
                    withAnimation(.spring()) {
                        selectedCharacter = nil
                    }
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(13)
//                        .background(.ultraThinMaterial, in: Circle())
                }
                .glassEffect(.regular, in: .circle)
                .padding(20),
                alignment: .topLeading
            )
            .overlay(
                Button(action: {
                    Task {
                        await toggleHome()
                    }
                }) {
                    let shown = (selectedCharacter?.isShown ?? character.isShown)
                    Image(systemName: shown ? "house.fill" : "house")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(shown ? .pink : .white.opacity(0.85))
                        .padding(11)
//                        .background(.ultraThinMaterial, in: Circle())
                }
                .glassEffect(.regular, in: .circle)
                .padding(15)
                .padding(.trailing, 55),
                alignment: .topTrailing
            )
            .overlay(
                Button(action: {
                    Task {
                        await togglePin()
                    }
                }) {
                    let pinned = (selectedCharacter?.isPinned ?? character.isPinned)
                    Image(systemName: pinned ? "star.fill" : "star")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(pinned ? .yellow : .white.opacity(0.85))
                        .padding(11)
//                        .background(.ultraThinMaterial, in: Circle())
                }
                .glassEffect(.regular, in: .circle)
                .padding(15),
                alignment: .topTrailing
            )
            .rotation3DEffect(.degrees(isUnlocked ? 0 : 120), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(isUnlocked ? 1.0 : 0.5)
//            .opacity(0.7)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    isUnlocked = true
                }
            }
        }
    }

    private func togglePin() async {
        var cardToToggle = character
        
        let newPinState = !cardToToggle.isPinned
        
        cardToToggle.isPinned = newPinState
        selectedCharacter = cardToToggle
        
        if cardToToggle.isAchievementUnlocked {
            await FirebaseUpdateCardService.shared.setIsPinnedAchievement(card: cardToToggle, isPinned: newPinState)
        } else {
            await FirebaseUpdateCardService.shared.setIsPinned(card: cardToToggle, isPinned: newPinState)
        }
//        await FirebaseDCService.shared.fetchDCCard(card: cardToToggle)
    }
    
    private func toggleHome() async {
        var cardToToggle = character
        
        let newHomeState = !cardToToggle.isShown
        
        cardToToggle.isShown = newHomeState
        selectedCharacter = cardToToggle
        
        if cardToToggle.isAchievementUnlocked {
            await FirebaseUpdateCardService.shared.setIsShownAchievement(card: cardToToggle, isShown: newHomeState)
        } else {
            await FirebaseUpdateCardService.shared.setIsShown(card: cardToToggle, isShown: newHomeState)
        }
    }
}

#Preview {
    DreamCardCharacterInformationView(
        selectedCharacter: .constant(nil),
        character: CardModel(userID: "1", id: "1", name: "Big Red", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit.", image: "https://www.flaticon.com/svg/v2/svg/6666/6666245.svg", cardColor: .pink),
    )
}

