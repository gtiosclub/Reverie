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
    
    @Binding var showArchive: Bool
    
    @State private var dreamCount: Int = 0
    
//    @State private var showCardsCarousel: Bool = false
//    
//    @State private var currentPage: Int = 0
    
    var user = FirebaseLoginService.shared.currUser!
    
//    @Namespace private var animation
    
//    @State private var degrees: Double = 8.0
    private let lastUnlockTimeKey = "lastUnlockTime"
    
    @Binding var progress: Float

//    var progress: Float {
//        let calendar = Calendar.current
//        let now = Date()
//
//        let lastUnlockTimeInterval = UserDefaults.standard.double(forKey: lastUnlockTimeKey)
//        let lastUnlockTime: Date
//        
//        var components = DateComponents()
//        components.weekday = 1 // Sunday
//        components.hour = 20    // 6 PM
////        components.minute = 33  // 6:49 PM
//        
//        if lastUnlockTimeInterval == 0 {
//            
//            let mostRecentUnlockTime = calendar.nextDate(after: now,
//                                                         matching: components,
//                                                         matchingPolicy: .nextTime,
//                                                         direction: .backward) ?? (now - 7*24*60*60)
//            
//            lastUnlockTime = calendar.date(byAdding: .day, value: -7, to: mostRecentUnlockTime)!
//            
//            UserDefaults.standard.set(lastUnlockTime.timeIntervalSince1970, forKey: lastUnlockTimeKey)
//            
//        } else {
//            lastUnlockTime = Date(timeIntervalSince1970: lastUnlockTimeInterval)
//        }
//
//        let nextUnlockTime = calendar.date(byAdding: .day, value: 7, to: lastUnlockTime)!
//
//        let totalDuration = nextUnlockTime.timeIntervalSince(lastUnlockTime)
//        
//        let timeElapsed = now.timeIntervalSince(lastUnlockTime)
//        
//        let progressValue = Float(timeElapsed / totalDuration)
//        
//        // never > 1.0
//        return min(1.0, progressValue)
//        return 1.0
//    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 20) {
                    //                StickerView(characters: characters, selectedCharacter: $selectedCharacter)
                    HStack {
                        Text("Characters")
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
                    .padding(.top, geo.size.height * 0.08)
                    
                    StickerView(characters: $characters, selectedCharacter: $selectedCharacter)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    TimelineView(.periodic(from: .now, by: 60.0)) { context in
                        if progress != 1.0 {
                            let nextUnlockDate = getNextUnlockDate()
                            
                            let timeString = formatTimeRemaining(until: nextUnlockDate)
                            
                            Text(timeString)
                                .font(.headline.bold())
                                .foregroundColor(.white.opacity(0.9))
                        } else {
                            Text("Unlock Now!")
                                .font(.headline.bold())
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
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
                            // only allow tap if progress is 1.0
                            if progress == 1.0 {
                                withAnimation(.spring()) {
                                    // show the unlock view
                                    self.unlockCards = true
                                    
                                    let calendar = Calendar.current
                                    let now = Date()
                                    
                                    var unlockComponents = DateComponents()
                                    unlockComponents.weekday = 1 // Sunday
                                    unlockComponents.hour = 20 // 8 PM
                                    //                                unlockComponents.minute = 33 // 42 is 42 minutes
                                    
                                    // most recent Sunday 8 PM that has already passed
                                    let mostRecentUnlockTime = calendar.nextDate(after: now,
                                                                                 matching: unlockComponents,
                                                                                 matchingPolicy: .nextTime,
                                                                                 direction: .backward)!
                                    
                                    UserDefaults.standard.set(mostRecentUnlockTime.timeIntervalSince1970, forKey: lastUnlockTimeKey)
                                }
                            } else {
                                print("Not ready to unlock yet.")
                            }
                        }
                        .task {
                            self.dreamCount = user.dreams.count
                        }
                }
                .padding(.bottom, 120)
            }
            .background(.clear)
        }
    }
    
    private func getNextUnlockDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // target time: Sunday at 8 PM
        var components = DateComponents()
        components.weekday = 1 // 1 = Sunday
        components.hour = 20 // 8 PM = 20:00
//        components.minute = 33 // 42 is 42 minutes
        
        // find the next date that matches these components
        // if it's already past 8 PM on Sunday, this finds next Sunday.
        return calendar.nextDate(after: now,
                                matching: components,
                                matchingPolicy: .nextTime)!
    }

    private func formatTimeRemaining(until unlockDate: Date) -> String {
//        print("progress \(progress)")
        if progress == 1.0 {
            return "Unlock Now!"
        }
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute],
                                                        from: now,
                                                        to: unlockDate)
        
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        if days > 0 {
            return "Unlocks in \(days)d \(hours)h"
        } else if hours > 0 {
            return "Unlocks in \(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "Unlocks in \(minutes)m"
        } else {
            return "Unlock Now!"
        }
    }
}

//#Preview {
//    DreamCardView(isOnHomeScreen: .constant(false))
//}
