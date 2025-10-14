import SwiftUI

struct OneWayFlipJumpCard<Front: View, Back: View>: View {
    let front: Front
    let back: Back
    var cardWidth: CGFloat = 190
    var cornerRadius: CGFloat = 15
    var perspective: CGFloat = 0.9
    var onReadyToMove: (() -> Void)? = nil
    
    private var cardSize: CGSize {
        CGSize(width: cardWidth, height: cardWidth * (475.0/300.0))
    }
    
    @State private var angle: Double = 0
    @State private var yOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var shadow: CGFloat = 10
    @State private var revealedGlow: Bool = false
    @State private var locked: Bool = false
    @State private var crispFront = false

    
    private var isFlipped: Bool { angle >= 90 }
    
    var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(angle - 180), axis: (x: 0, y: 1, z: 0))
                .overlay(
                    LinearGradient(colors: [.clear, .white.opacity(0.35), .clear],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .opacity(revealedGlow ? 1 : 1)
                        .blendMode(.screen)
                )
                .blur(radius: crispFront ? 0 : 8)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            back
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(radius: shadow, y: shadow)
        .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 0, z: 0), perspective: perspective)
        .scaleEffect(scale)
        .offset(y: yOffset)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onTapGesture(perform: triggerOneWayFlip)
        .accessibilityLabel(isFlipped ? "Card revealed" : "Card faced down")
    }
    
    private func triggerOneWayFlip() {
        guard !locked else { return }
        locked = true
        revealedGlow = false
        
        withAnimation(.spring(response: 0.32, dampingFraction: 0.75)) {
            yOffset = -400
            scale = 2
            shadow = 20
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.75)) {
                angle = 200
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {
            withAnimation(.interpolatingSpring(stiffness: 260, damping: 22)) {
                angle = 180
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.82) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.7)) {
                yOffset = 0
                scale = 1.0
                shadow = 10
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.02) {
            withAnimation(.easeOut(duration: 0.28)) {
                revealedGlow = true
            }
            crispFront = true
            withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
                scale = 1.15
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    scale = 1.0
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onReadyToMove?()
            }
        }
    }
}

struct CharacterCard: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let backgroundColor: Color
    let role: String
    let description: String
    let icon: String
    let color2: Color
}

struct BottomStack_ToCenteredOverlappingColumn_View: View {
    @State private var cards: [CharacterCard] = [
        .init(name: "LIZZY",  backgroundColor: .green,  role: "The Architect",
              description: "Builds the landscape of your dreams", icon: "lizard.fill", color2: .blue),
        .init(name: "BOLT",   backgroundColor: .yellow, role: "The Spark",
              description: "Ignites new ideas when you need them", icon: "tortoise.fill", color2: .orange),
        .init(name: "AURORA", backgroundColor: .purple, role: "The Muse",
              description: "Guides your imagination into focus", icon: "bird.fill", color2: .pink),
        .init(name: "ATLAS",  backgroundColor: .cyan,   role: "The Guardian",
              description: "Carries your goals across the finish line", icon: "fish.fill", color2: .mint)
    ]
    @State private var revealedOrder: [UUID] = []
    
    private let cardWidth: CGFloat = 190
    private var cardSize: CGSize { CGSize(width: cardWidth, height: cardWidth * (475.0/300.0)) }
    private let stackOffsetStep = CGSize(width: -18, height: -10)
    private let topInset: CGFloat = 16
    private let overlapFraction: CGFloat = 0.65
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(cards.enumerated()), id: \.element.id) { idx, card in
                    let isRevealed = revealedOrder.contains(card.id)
                    let colIndex = revealedOrder.firstIndex(of: card.id)
                    
                    OneWayFlipJumpCard(
                        front: CharacterUnlockedView(
                            name: card.name,
                            backgroundColor: card.backgroundColor,
                            role: card.role,
                            description: card.description,
                            icon: card.icon,
                            color2: card.color2
                        )
                        .frame(width: 300, height: 475)
                        .scaleEffect(cardWidth / 300),
                        back: backFace,
                        cardWidth: cardWidth
                    ) {
                        guard !revealedOrder.contains(card.id) else { return }
                        withAnimation(.spring(response: 0.72, dampingFraction: 0.88)) {
                            revealedOrder.append(card.id)
                        }
                    }
                    .position(position(for: idx,
                                       isRevealed: isRevealed,
                                       columnIndex: colIndex,
                                       in: geo.size))
                    .zIndex(zOrder(for: card.id, stackIndex: idx))
                    .animation(.spring(response: 0.72, dampingFraction: 0.88),
                               value: revealedOrder)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
        }
        .padding(.horizontal, 8)
    }
    
    private var backFace: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(colors: [.gray.opacity(0.25), .gray.opacity(0.15)],
                                     startPoint: .top, endPoint: .bottom))
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                .foregroundStyle(.secondary)
            VStack(spacing: 6) {
                Image(systemName: "questionmark")
                    .font(.system(size: 40, weight: .semibold))
                Text("Tap to reveal")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func position(for stackIndex: Int,
                          isRevealed: Bool,
                          columnIndex: Int?,
                          in container: CGSize) -> CGPoint {
        if let r = columnIndex, isRevealed {
            let x = container.width / 2
            let step = cardSize.height * (1 - overlapFraction)
            let y = topInset + cardSize.height / 2 + CGFloat(r) * step
            return CGPoint(x: x, y: y)
        } else {
            let baseX = container.width * 0.5
            let baseY = container.height
            let x = baseX + CGFloat(stackIndex) * stackOffsetStep.width
            let y = baseY + CGFloat(stackIndex) * stackOffsetStep.height
            return CGPoint(x: x, y: y)
        }
    }
    
    private func zOrder(for id: UUID, stackIndex: Int) -> Double {
        if let idx = revealedOrder.firstIndex(of: id) {
            return 1000 + Double(idx)
        } else {
            return Double(stackIndex)
        }
    }
}

#Preview {
    BottomStack_ToCenteredOverlappingColumn_View()
        .previewLayout(.fixed(width: 430, height: 820))
}
