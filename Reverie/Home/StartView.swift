//
//  HomeDCConnectionView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/12/25.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var ts: TabState
    @State private var isOnHomeScreen = false
    @State private var characters: [CardModel] = FirebaseLoginService.shared.currUser?.dreamCards ?? []
    @State private var selectedCharacter: CardModel? = nil
    @State private var unlockCards: Bool = false
    @State private var lockedCharacters: [CardModel] = []
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    HomeView(characters: $characters)
                        .frame(height: UIScreen.main.bounds.height)
                    
                    DreamCardView(
                        isOnHomeScreen: $isOnHomeScreen,
                        characters: $characters,
                        lockedCharacters: $lockedCharacters,
                        selectedCharacter: $selectedCharacter,
                        unlockCards: $unlockCards
                    )
                        .frame(height: UIScreen.main.bounds.height)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                TabbarView()
            }
            
            if let character = selectedCharacter {
                DreamCardCharacterInformationView(
                    selectedCharacter: $selectedCharacter,
                    character: character,
//                    isOnHomeScreen: $isOnHomeScreen
                )
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.9)), removal: .opacity))
                .id(character.id)
            }
                        
            if unlockCards {
                CardUnlockView(
                    unlockCards: $unlockCards,
                    cards: lockedCharacters
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .onAppear {
            ts.activeTab = .home
        }
        .task {
            self.lockedCharacters = characters.filter { !$0.isUnlocked }
        }
//        .task {
//            await refreshLockedCharacters()
//        }
        .onChange(of: unlockCards) { _, newValue in
            if !newValue {
                Task { await refreshLockedCharacters() }
            }
        }
        .onChange(of: selectedCharacter) { _, newValue in
             if newValue == nil {
                 Task { await refreshLockedCharacters() }
             }
         }
    }
    
    func refreshLockedCharacters() async {
        do {
            self.characters = try await FirebaseDCService.shared.fetchDCCards()
            self.lockedCharacters = characters.filter { !$0.isUnlocked }
        } catch {
            print("Error refreshing locked characters: \(error)")
        }
    }
}

#Preview {
    StartView()
        .environment(FirebaseLoginService.shared)
        .environmentObject(TabState())
}
