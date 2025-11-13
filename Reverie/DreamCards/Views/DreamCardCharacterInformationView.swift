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
    @State private var dream: DreamModel? = nil
    
    init(selectedCharacter: Binding<CardModel?>,
         character: CardModel) {
        self._selectedCharacter = selectedCharacter
        self.character = character
    }

    var body: some View {
        ZStack {
            backgroundView
            cardView
                .transition(.scale.combined(with: .opacity))
                .rotation3DEffect(.degrees(isUnlocked ? 0 : 120), axis: (x: 0, y: 1, z: 0))
                .scaleEffect(isUnlocked ? 1.0 : 0.5)
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                        isUnlocked = true
                    }
                }
        }
        .task { await loadDream() }
    }

    private var backgroundView: some View {
        Color.black.opacity(0.8)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.spring()) { selectedCharacter = nil }
            }
    }

    private var cardView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                imageSection
                textSection
                Spacer()
                dreamButton
                    .padding(.bottom, 30)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(width: 320, height: 520)
        .background(cardBackground)
        .overlay(backButton, alignment: .topLeading)
        .overlay(homeButton, alignment: .topTrailing)
        .overlay(pinButton, alignment: .topTrailing)
    }

    private var imageSection: some View {
        AsyncImage(url: URL(string: character.image ?? "")) { phase in
            switch phase {
            case .empty: ProgressView().tint(.white)
            case .success(let image): image.resizable().scaledToFit()
            case .failure:
                Image(systemName: "globe.americas.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white.opacity(0.8))
            @unknown default: EmptyView()
            }
        }
        .padding(.top, 60)
        .frame(width: character.isAchievementUnlocked ? 250 : 180,
               height: character.isAchievementUnlocked ? 250 : 180)
        .foregroundColor(.white)
    }

    private var textSection: some View {
        VStack(spacing: 8) {
            Text(character.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(character.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var dreamButton: some View {
        Group {
            if let dream = dream {
                NavigationLink(destination: DreamEntryView(dream: dream, backToArchive: false)) {
                    Text("Dream details")
                        .foregroundColor(.indigo)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.3))
                        )
                }
            } else {
                Text("Dream details")
                    .foregroundColor(.indigo)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black.opacity(0.85))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(character.cardColor.swiftUIColor.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: character.cardColor.swiftUIColor.opacity(0.4), radius: 15)
    }

    private var backButton: some View {
        Button {
            withAnimation(.spring()) { selectedCharacter = nil }
        } label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white.opacity(0.85))
                .padding(13)
        }
        .glassEffect(.regular, in: .circle)
        .padding(20)
    }

    private var homeButton: some View {
        Button {
            Task { await toggleHome() }
        } label: {
            let shown = (selectedCharacter?.isShown ?? character.isShown)
            Image(systemName: shown ? "house.fill" : "house")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(shown ? .pink : .white.opacity(0.85))
                .padding(11)
        }
        .glassEffect(.regular, in: .circle)
        .padding(15)
        .padding(.trailing, 55)
    }

    private var pinButton: some View {
        Button {
            Task { await togglePin() }
        } label: {
            let pinned = (selectedCharacter?.isPinned ?? character.isPinned)
            Image(systemName: pinned ? "star.fill" : "star")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(pinned ? .yellow : .white.opacity(0.85))
                .padding(11)
        }
        .glassEffect(.regular, in: .circle)
        .padding(15)
    }

    private func loadDream() async {
        dream = try? await FirebaseDreamService.shared.fetchDream(dreamID: character.id)
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
        character: CardModel(userID: "1", id: "1", name: "Big Red", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit.", image: "https://www.flaticon.com/svg/v2/svg/6666/6666245.svg", cardColor: .pink)
    )
}
