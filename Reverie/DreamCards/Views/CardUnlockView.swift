import SwiftUI

struct CardUnlockView: View {
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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.9)
                   .ignoresSafeArea()
                   .onTapGesture {
                       // tap the background to dismiss
                       withAnimation {
                           if revealedCount == cards.count {
                               unlockCards = false
                           }
                       }
                   }
                   .zIndex(-5)
                
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
                        back: { BackCardView() }
                    )
                    // reveal ontap
                    .onTapGesture {
                        guard !isRevealed else { return }
                        revealedCount += 1
                    }
                    // card size based on if it has been clicked
                    .scaleEffect(isRevealed ? 0.80 : 1.0)
                    // get position (see private func below)
                    .position(position(for: index, isRevealed: isRevealed, in: geometry.size))
                    // properly stack
                    .zIndex(isRevealed ? Double(index) : Double(-index))
                    // animate the card being launched once clicked
                    .animation(.spring(response: 0.65, dampingFraction: 0.75), value: revealedCount)
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
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 15).strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 6])).foregroundStyle(.secondary)
            VStack(spacing: 6) {
                Image(systemName: "questionmark").font(.system(size: 40, weight: .semibold))
                Text("Tap to reveal").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .frame(width: 190, height: 190 * (475.0/300.0))
    }
}

#Preview {
    CardUnlockView(unlockCards: .constant(true), cards: [CardModel.init(userID: "1", id: "1", name: "LIZZY", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .pink)])
}
