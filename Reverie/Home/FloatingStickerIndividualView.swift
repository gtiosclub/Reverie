//
//  FloatingStickerIndividualView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/13/25.
//

import SwiftUI

struct FloatingStickerIndividualView: View {
    let character: CardModel
    let screenSize: CGSize

    @State private var position: CGPoint = .zero
    @State private var rotation: Angle = .zero
    @State private var scale: CGFloat = 1.0
    
    // Tracks whether the sticker is actively being dragged
    @State private var isBeingDragged: Bool = false
    // Current velocity of the sticker used for flick/throw motion
    @State private var velocity: CGSize = .zero
    // Temporary drag offset to show movement during drag
    @State private var dragOffset: CGSize = .zero
    @State private var isPaused: Bool = false
    @State private var hasAlignedToTouch = false
    
    
    var body: some View {
        AsyncImage(url: URL(string: character.image ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            default:
                EmptyView()
            }
        }
        .frame(width: 75, height: 75)
        .scaleEffect(scale)
        .rotationEffect(rotation)
        .position(x: position.x + dragOffset.width, y: position.y + dragOffset.height)
        .gesture(
            LongPressGesture(minimumDuration: 0.25)
                .onEnded { _ in
                    withAnimation(.none) { isPaused = true }
                    isBeingDragged = true
                    hasAlignedToTouch = false
                }
                .sequenced(before: DragGesture())
                .onChanged { value in
                    switch value {
                    case .second(true, let drag?):
                        if !hasAlignedToTouch {
                            withAnimation(.none){
                                position = drag.startLocation
                            }
                            hasAlignedToTouch = true
                        }
                        dragOffset = drag.translation
                    default:
                        dragOffset = .zero
                    }
                }
                .onEnded { value in
                    switch value {
                    case .second(true, let drag?):
                        position.x += drag.translation.width
                        position.y += drag.translation.height
                        // Calculate flick velocity based on drag gesture to simulate throw speed
                        let dragVelocity = drag.predictedEndLocation - drag.location
                        velocity = CGSize(width: dragVelocity.width / 40, height: dragVelocity.height / 40)
                    default:
                        break
                    }
                    dragOffset = .zero
                    isBeingDragged = false
                    applyThrowAnimation()
                }
        )
        .onAppear {
            self.position = CGPoint(
                x: CGFloat.random(in: 40...(screenSize.width - 40)),
                y: CGFloat.random(in: 40...(screenSize.height - 40))
            )
            startFloatingAnimation()
        }
    }
    
    private func startFloatingAnimation() {
        guard !isBeingDragged else { return }
        
        let newPosition = CGPoint(
            x: CGFloat.random(in: 40...(screenSize.width - 40)),
            y: CGFloat.random(in: 40...(screenSize.height - 40))
        )
        
        let newRotation = Angle.degrees(Double.random(in: -90...90))
        let newScale = CGFloat.random(in: 0.8...1.2)
        let duration = Double.random(in: 7...12)
        
        withAnimation(.easeInOut(duration: duration)) {
            self.position = newPosition
            self.rotation = newRotation
            self.scale = newScale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            startFloatingAnimation()
        }
    }
    
    // Start throw animation applying bounce and friction physics
    private func applyThrowAnimation() {
        // Timer-driven physics loop for updating position and velocity during throw
        let throwDuration = 0.02 // small step for smoother updates

        Timer.scheduledTimer(withTimeInterval: throwDuration, repeats: true) { timer in
            // Update position using velocity
            position.x += velocity.width * CGFloat(throwDuration * 60)
            position.y += velocity.height * CGFloat(throwDuration * 60)

            // Bounce horizontally when hitting left or right edges
            if position.x < 40 || position.x > screenSize.width - 40 {
                velocity.width *= -0.8
                position.x = min(max(position.x, 40), screenSize.width - 40)
            }

            // Bounce vertically when hitting top or bottom edges
            if position.y < 40 || position.y > screenSize.height - 40 {
                velocity.height *= -0.8
                position.y = min(max(position.y, 40), screenSize.height - 40)
            }

            // Gradually slow down the sticker motion using friction
            velocity.width *= 0.95
            velocity.height *= 0.95

            // Stop motion once velocity is nearly zero and resume floating animation
            if abs(velocity.width) < 0.1 && abs(velocity.height) < 0.1 {
                timer.invalidate()
                velocity = .zero
                startFloatingAnimation()
            }
        }
    }
}

private func - (lhs: CGPoint, rhs: CGPoint) -> CGSize {
    CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
}
