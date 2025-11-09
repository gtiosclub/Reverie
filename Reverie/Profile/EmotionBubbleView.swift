
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

#Preview {
    EmotionBubbleView(size:(100), color:Color.red, start:CGPoint(x:200,y:300), jitter:10)
        
}
