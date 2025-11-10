import SwiftUI

struct CardUnlockView: View {
    @Namespace private var cardNamespace // Added namespace for matchedGeometryEffect
//    @Environment(FirebaseDCService.self) private var fbdcs
    @Binding var unlockCards: Bool
    
    // how many cards have been revealed?
    @State private var revealedCount = 0
    
    // card information
//    @State private var cards: [CardModel] = [
//        .init(userID: "1", id: "1", name: "LIZZY", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .blue),
//        .init(userID: "2", id: "2", name: "BOLT", description: "Ignites new ideas when you need them", image: "tortoise.fill", cardColor: .purple),
//        .init(userID: "3", id: "3", name: "AURORA", description: "Guides your imagination into focus", image: "bird.fill", cardColor: .pink),
//        .init(userID: "4", id: "4", name: "ATLAS", description: "Carries your goals across the finish line", image: "fish.fill", cardColor: .yellow)
//    ]
    let cards: [CardModel]
    private let cardWidth: CGFloat = 190
    private let cardHeight: CGFloat = 190 * (475.0/300.0)
    
    private var allRevealed: Bool { revealedCount >= cards.count && !cards.isEmpty }
    @State private var showHorizontal = false
    
    // New state property controlling whether the revealed cards deck is expanded horizontally
    @State private var expandedDeck = false
    
    init(unlockCards: Binding<Bool>, cards: [CardModel], initialRevealedCount: Int = 0) {
        self._unlockCards = unlockCards
        self.cards = cards
        self._revealedCount = State(initialValue: max(0, min(initialRevealedCount, cards.count)))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.9)
                   .ignoresSafeArea()
                   .onTapGesture {
                       // tap the background to dismiss
                       withAnimation {
                           if showHorizontal {
                               unlockCards = false
                           }
                       }
                   }
                   .zIndex(-5)
                
                if showHorizontal {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(cards, id: \.id) { card in
                                let scale = cardWidth / 300.0 // CharacterUnlockedView uses 300x475 internally
                                ZStack {
                                    CharacterUnlockedView(
                                        card: CardModel(
                                            userID: card.userID,
                                            id: card.id,
                                            name: card.name,
                                            description: card.description,
                                            image: card.image ?? "questionmark",
                                            cardColor: card.cardColor
                                        )
                                    )
                                    .scaleEffect(scale, anchor: .center) // scale down uniformly to fit
                                    .matchedGeometryEffect(id: card.id, in: cardNamespace) // Added matchedGeometryEffect for smooth transition
                                }
                                .frame(width: cardWidth, height: cardHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)) // keep rounded edges
                                .shadow(color: .black.opacity(0.25), radius: 12, y: 8)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    //.transition(.move(edge: .bottom).combined(with: .opacity)) // Removed transition to rely on matchedGeometryEffect
                    .animation(.spring(response: 0.6, dampingFraction: 0.85), value: showHorizontal) // Linked animation to showHorizontal for consistency
                } else {
                    ForEach(cards.indices, id: \.self) { index in
                        // what is the ith card?
                        let card = cards[index]
                        // card is revealed once its index has been past
                        let isRevealed = index < revealedCount

                        FlippingCardView(
                            isFlipped: isRevealed,
                            // front
                            front: {
                                CharacterUnlockedView(
                                    card: CardModel(
                                        userID: card.userID,
                                        id: card.id,
                                        name: card.name,
                                        description: card.description,
                                        image: card.image ?? "questionmark",
                                        cardColor: card.cardColor
                                ))
                            },
                            // back of card -> see BackCardView()
                            back: {
                                BackCardView(
                                    card: CardModel(
                                        userID: card.userID,
                                        id: card.id,
                                        name: card.name,
                                        description: card.description,
                                        image: card.image ?? "questionmark",
                                        cardColor: card.cardColor
                                    ))
                            }
                        )
                        // reveal ontap
                        .onTapGesture {
                            guard !isRevealed else { return }
                            withAnimation(.spring(response: 0.65, dampingFraction: 0.75)) {
                                revealedCount += 1
                            }
                            if revealedCount == cards.count {
                                // Delay switching layouts until the final flip animation visually completes
                                // This longer delay ensures the final card finishes its animation before the transition starts
                                let delay = 1.85 // increased to 1.85 to allow settling
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    withAnimation(.spring(response: 1.5, dampingFraction: 1.5)) {
                                        showHorizontal = true
                                    }
                                }
                                // Additional delay to trigger the expandedDeck animation slightly after the last flip finishes
                                // This ensures the expansion animation is synchronized with the flip completion for smooth UX
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 2) {
                                    withAnimation(.easeInOut(duration: 1.0)) {
                                        expandedDeck = true
                                    }
                                }
                            }
                            Task {
                                if card.isAchievementUnlocked {
                                    await FirebaseUpdateCardService.shared.toggleIsUnlockedAchievement(card: card)
                                } else {
                                    await FirebaseUpdateCardService.shared.toggleIsUnlocked(card: card)
                                }
                            }
                        }
                        // card size based on if it has been clicked
                        .scaleEffect(isRevealed ? 0.80 : 1.0)
                        // get position (see private func below)
                        .position(position(for: index, isRevealed: isRevealed, in: geometry.size))
                        // When all cards are revealed and expandedDeck is true, spread the cards horizontally with animated offset
                        .offset(x: isRevealed && expandedDeck ? horizontalOffset(for: index) : 0)
                        // properly stack
                        .zIndex(isRevealed ? Double(index) : Double(cards.count - index))
                        .matchedGeometryEffect(id: card.id, in: cardNamespace) // Added matchedGeometryEffect for smooth transition
                        // animate the card being launched once clicked and the offset when expandedDeck changes
                        .animation(.spring(response: 0.65, dampingFraction: 0.75), value: revealedCount)
                        // Duration increased to 4 seconds for a smoother, cinematic expansion transition
                        .animation(.easeInOut(duration: 4.0), value: expandedDeck)
                    }
                }
            }
        }
//        .background(Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea())
        // looks better with background for testing
    }
    
    private func position(for index: Int, isRevealed: Bool, in containerSize: CGSize) -> CGPoint {
        if isRevealed {
            // cards will just stack for now
            let x = containerSize.width / 2
            let y = containerSize.height / 3
            return CGPoint(x: x, y: y)
            
        } else {
            // stacked cards at bottom of screen
            let totalCards = cards.count
            // offset x a tiny bit
            let x = (containerSize.width / 1.8) + CGFloat( (totalCards - 1 - index) * -20)
            // offset y a tiny bit
            let y = containerSize.height - 40 + CGFloat( (totalCards - 1 - index) * 10)
            // get point on screen
            return CGPoint(x: x, y: y)
        }
    }
    
    // New helper function to calculate horizontal offset for spreading cards when expandedDeck is true
    private func horizontalOffset(for index: Int) -> CGFloat {
        // Calculate the center index of the revealed cards
        let centerIndex = CGFloat(revealedCount - 1) / 2.0
        // Spread cards horizontally with spacing of 40 points between them
        let spacing: CGFloat = 40
        // Offset relative to center to spread cards evenly
        return (CGFloat(index) - centerIndex) * spacing
    }
}

struct FlippingCardView<Front: View, Back: View>: View {
    let isFlipped: Bool
    @ViewBuilder let front: () -> Front
    @ViewBuilder let back: () -> Back
    
    // different movements
    private enum AnimationPhase: CaseIterable {
        case initial, jump, flip, land, settle, finish
    }
    
    var body: some View {
        PhaseAnimator(AnimationPhase.allCases, trigger: isFlipped) { phase in
            // dont go back to initial
            let isAtRestAndFlipped = isFlipped && phase == .initial
            // stay upright once flipepd
            let angle = isAtRestAndFlipped ? 180 : rotationAngle(for: phase)
            let isPastHalfway = angle >= 90
            
            ZStack {
                // front card
                front()
                    // rotation - 180 (get to front)
                    .rotation3DEffect(.degrees(angle - 180), axis: (x: 0, y: 1, z: 0))
                    // dont allow card to be see through
                    .opacity(isPastHalfway ? 1 : 0)
                // back card
                back()
                    // rotation of back card after click
                    .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
                    // dont allow card to be see through
                    .opacity(isPastHalfway ? 0 : 1)
            }
            // movements on screen
            .scaleEffect(isAtRestAndFlipped ? 1.0 : (phase == .settle ? 1.15 : 1.0))
            .offset(y: isAtRestAndFlipped ? 0 : (phase == .jump ? -135 : 0))
            .shadow(radius: isAtRestAndFlipped ? 10 : (phase == .jump ? 30 : 10),
                    y: isAtRestAndFlipped ? 10 : (phase == .jump ? 30 : 10))
            
        } animation: { phase in
            // response -> how quick
            // damping -> how much wobble
            switch phase {
            case .initial: .linear(duration: 0)
            case .jump: .spring(response: 0.4, dampingFraction: 0.8)
            case .flip: .spring(response: 1.2, dampingFraction: 0.7)
            case .land: .interpolatingSpring(stiffness: 180, damping: 20)
            case .settle: .spring(response: 0.3, dampingFraction: 0.8)
            case .finish: .spring(response: 0.3, dampingFraction: 0.8)
            }
        }
    }
    
    // rotation amount (can modify for more or less flipping animation)
    private func rotationAngle(for phase: AnimationPhase) -> Double {
        switch phase {
        case .initial: return 0
        case .jump: return 10
        case .flip: return 560
        case .land, .settle, .finish: return 540
        }
    }
}

struct BackCardView: View {
    @State var card: CardModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 15).stroke(card.cardColor, lineWidth: 3)
//            VStack(spacing: 6) {
//                Image(systemName: "questionmark").font(.system(size: 40, weight: .semibold))
            Text("Tap to reveal").font(.footnote).foregroundStyle(card.cardColor)
//            }
        }
        .frame(width: 190, height: 190 * (475.0/300.0))
    }
}

#Preview("1 unlocked") {
    let demoCards: [CardModel] = [
        .init(userID: "1", id: "1", name: "LIZZY", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .pink),
        .init(userID: "2", id: "2", name: "BOLT", description: "Ignites new ideas when you need them", image: "tortoise.fill", cardColor: .purple),
        .init(userID: "3", id: "3", name: "AURORA", description: "Guides your imagination into focus", image: "bird.fill", cardColor: .blue)
    ]
    return CardUnlockView(unlockCards: .constant(true), cards: demoCards, initialRevealedCount: 1)
}

#Preview("2 unlocked") {
    let demoCards: [CardModel] = [
        .init(userID: "1", id: "1", name: "LIZZY", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .pink),
        .init(userID: "2", id: "2", name: "BOLT", description: "Ignites new ideas when you need them", image: "tortoise.fill", cardColor: .purple),
        .init(userID: "3", id: "3", name: "AURORA", description: "Guides your imagination into focus", image: "bird.fill", cardColor: .blue)
    ]
    return CardUnlockView(unlockCards: .constant(true), cards: demoCards, initialRevealedCount: 2)
}

#Preview("All unlocked") {
    let demoCards: [CardModel] = [
        .init(userID: "1", id: "1", name: "LIZZY", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .pink),
        .init(userID: "2", id: "2", name: "BOLT", description: "Ignites new ideas when you need them", image: "tortoise.fill", cardColor: .purple),
        .init(userID: "3", id: "3", name: "AURORA", description: "Guides your imagination into focus", image: "bird.fill", cardColor: .blue)
    ]
    return CardUnlockView(unlockCards: .constant(true), cards: demoCards, initialRevealedCount: demoCards.count)
}
