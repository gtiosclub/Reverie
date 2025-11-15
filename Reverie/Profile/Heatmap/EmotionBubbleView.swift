
//
//  EmotionBubble.swift
//  Reverie
//
//  Created by Abhiram Raju on 10/14/25.
//
import SwiftUI
struct EmotionBubbleView: View {
    let size: CGFloat
    let color: Color
    let start: CGPoint
    let jitter: CGFloat
    @State private var position: CGPoint
    @State private var rotation: Angle = .degrees(0)
    @State private var scale: CGFloat = 1.0
    init(size: CGFloat, color: Color, start: CGPoint, jitter: CGFloat) {
        self.size = size
        self.color = color
        self.start = start
        self.jitter = jitter
        _position = State(initialValue: start)
    }
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.95),
                            color.opacity(0.65),
                            .black.opacity(0.88)
                        ]),
                        center: .center,
                        startRadius: max(8, size * 0.08),
                        endRadius: size * 0.65
                    )
                )
                .shadow(color: color.opacity(0.45), radius: 12, x: 6, y: 8)
            Circle()
                .strokeBorder(.white.opacity(0.12), lineWidth: max(2, size * 0.025))
        }
        .frame(width: size, height: size)
        .position(position)
        .rotationEffect(rotation)
        .scaleEffect(scale)
        .onAppear { startFloatingAnimation() }
        .accessibilityHidden(true)
    }
    // very light, continuous float within a tiny square around `start`
    private func startFloatingAnimation() {
        let target = CGPoint(
            x: start.x + CGFloat.random(in: -jitter...jitter),
            y: start.y + CGFloat.random(in: -jitter...jitter)
        )
        let newRotation = Angle.degrees(Double.random(in: -8...8))
        let newScale    = CGFloat.random(in: 0.96...1.04)
        let duration    = Double.random(in: 8...14)
        withAnimation(.easeInOut(duration: duration)) {
            position = target
            rotation = newRotation
            scale = newScale
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            startFloatingAnimation()
        }
    }
}

struct EmotionBubbleChart: View {
    let dreams: [DreamModel]
    @State private var selectedBubble: EmotionBubble?
    
    private let bubbleSlots: [CGPoint] = [
        CGPoint(x: 0.28, y: 0.32),
        CGPoint(x: 0.55, y: 0.24),
        CGPoint(x: 0.78, y: 0.40),
        CGPoint(x: 0.30, y: 0.62),
        CGPoint(x: 0.58, y: 0.58),
        CGPoint(x: 0.78, y: 0.68),
        CGPoint(x: 0.44, y: 0.78)
    ]
    private let chartHeight: CGFloat = 320
    
    var body: some View {
        Group {
            if emotionBubbles.isEmpty {
                placeholderContainer
            } else {
                chartContainer
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var placeholderContainer: some View {
        RoundedRectangle(cornerRadius: 36, style: .continuous)
            .fill(containerColor)
            .overlay(
                VStack(spacing: 8) {
                    Text("Log dreams to unlock your mood chart.")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Once moods are recorded, their bubbles will appear here.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            )
            .overlay(
                RoundedRectangle(cornerRadius: 36)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .frame(height: chartHeight)
    }
    
    private var chartContainer: some View {
        VStack {
            Text("Tap to view the percentage of your dream moods")
                .font(.subheadline)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
            ZStack {
                //            RoundedRectangle(cornerRadius: 36, style: .continuous)
                //                .fill(containerColor)
                //                .overlay(
                //                    RoundedRectangle(cornerRadius: 36)
                //                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                //                )
                //                .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 12)
                
                GeometryReader { geo in
                    let chartSize = geo.size
                    let minSide = min(chartSize.width, chartSize.height)
                    let maxCount = max(emotionBubbles.map(\.count).max() ?? 1, 1)
                    
                    ZStack {
                        ForEach(emotionBubbles) { bubble in
                            let slot = bubbleSlots[bubble.slotIndex]
                            let center = CGPoint(x: slot.x * chartSize.width,
                                                 y: slot.y * chartSize.height)
                            EmotionBubbleView(
                                size: bubbleSize(for: bubble, minSide: minSide, maxCount: maxCount),
                                color: bubble.color,
                                start: center,
                                jitter: max(16, minSide * 0.05)
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    selectedBubble = bubble
                                }
                            }
                        }
                    }
                    .frame(width: chartSize.width, height: chartSize.height)
                }
                .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                
                if let bubble = selectedBubble {
                    Color.black.opacity(0.35)
                        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                        .onTapGesture { dismissSelection() }
                        .transition(.opacity)
                    
                    EmotionBubbleDetailCard(bubble: bubble, onClose: dismissSelection)
                        .padding(.horizontal, 24)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: chartHeight)
            .darkGloss()
        }

    }
    
    private var emotionBubbles: [EmotionBubble] {
        let counts = dreams.reduce(into: [DreamModel.Emotions: Int]()) { partialResult, dream in
            partialResult[dream.emotion, default: 0] += 1
        }
        let total = max(1, dreams.count)
        let sorted = counts.sorted { $0.value > $1.value }
        
        return sorted.enumerated().compactMap { index, element in
            guard index < bubbleSlots.count else { return nil }
            return EmotionBubble(
                emotion: element.key,
                count: element.value,
                percentage: Double(element.value) / Double(total),
                slotIndex: index
            )
        }
    }
    
    private func bubbleSize(for bubble: EmotionBubble, minSide: CGFloat, maxCount: Int) -> CGFloat {
        let base = minSide * 0.22
        let extra = minSide * 0.18
        let scale = CGFloat(bubble.count) / CGFloat(maxCount)
        return min(base + (scale * extra), minSide * 0.5)
    }
    
    private func dismissSelection() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            selectedBubble = nil
        }
    }
    
    private var containerColor: Color { .profileContainer }
    
    struct EmotionBubble: Identifiable, Equatable {
        let emotion: DreamModel.Emotions
        let count: Int
        let percentage: Double
        let slotIndex: Int
        
        var id: DreamModel.Emotions { emotion }
        var color: Color { DreamModel.emotionColors(emotion: emotion) }
        var formattedPercentage: String {
            let value = (percentage * 100).rounded()
            return "\(Int(value))%"
        }
    }
}

private struct EmotionBubbleDetailCard: View {
    let bubble: EmotionBubbleChart.EmotionBubble
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                bubbleGlyph
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.headline.bold())
                        .foregroundColor(.white.opacity(0.9))
                        .padding(8)
                        .background(Color.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(bubble.emotion.displayName)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text(bubble.formattedPercentage)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
            }
            
            Text(bubble.emotion.detailDescription)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(detailBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: bubble.color.opacity(0.4), radius: 22, x: 0, y: 12)
    }
    
    private var bubbleGlyph: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [bubble.color.opacity(0.95), bubble.color.opacity(0.4)],
                    center: .topLeading,
                    startRadius: 6,
                    endRadius: 38
                )
            )
            .frame(width: 64, height: 64)
            .overlay(
                Circle().stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: bubble.color.opacity(0.4), radius: 12, x: 0, y: 6)
    }
    
    private var detailBackground: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        bubble.color.opacity(0.55),
                        Color.black.opacity(0.65)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

#Preview {
    EmotionBubbleView(size:(100), color:Color.red, start:CGPoint(x:200,y:300), jitter:10)
}
