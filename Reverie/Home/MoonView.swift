//
//  Moon.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/23/25.
//

import SwiftUI

struct MoonView: View {
    var body: some View {
        Moon()
    }
}

struct Moon: View {
    @State private var position: CGPoint = .zero
    @State private var rotation: Angle = .zero
    @State private var scale: CGFloat = 1.0
    
    @State private var isBeingDragged: Bool = false
    // Tracks user's drag offset while moving the moon
    @State private var dragOffset: CGSize = .zero
    // Velocity applied when flicking the moon (controls throw speed and direction)
    @State private var velocity: CGSize = .zero
    // Tracks whether the moon is currently being thrown to pause eye animation
    @State private var isThrown: Bool = false
    @State private var isPaused: Bool = false
    @State private var hasAlignedToTouch = false
    
    var body: some View {
        GeometryReader { geometry in
//            ZStack {
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 140, height: 140)
//                    .blur(radius: 30)
//                    .opacity(0.35)
//
//                Circle()
//                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: [Color(white: 0.95), Color(white: 0.8)]),
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .frame(width: 120, height: 120)
//                
//                MoonFaceView(isThrown: isThrown)
//            }
            Image("Moon")
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
            .rotationEffect(rotation)
            .scaleEffect(scale)
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
                            break
                        }
                    }
                    .onEnded { value in
                        switch value {
                        case .second(true, let drag?):
                            // Calculate flick velocity based on drag speed to simulate realistic throw physics
                            let dragVelocity = drag.velocity
                            velocity = CGSize(width: dragVelocity.width / 50, height: dragVelocity.height / 50)
                            position.x += drag.translation.width
                            position.y += drag.translation.height
                            dragOffset = .zero
                            isBeingDragged = false
                            // Set thrown state when flicked to disable eye movement
                            isThrown = true
                            // Begin physics-based throw animation including wall bounces and gradual slowdown
                            animateThrow(screenSize: geometry.size)
                        default:
                            dragOffset = .zero
                            isBeingDragged = false
                        }
                    }
            )
            .onAppear {
                self.position = CGPoint(x: geometry.size.width / 4, y: geometry.size.height / 4)
                startFloating(screenSize: geometry.size)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    
    private func startFloating(screenSize: CGSize) {
        guard !isBeingDragged else { return }
        
        let safeXRange = (60...screenSize.width - 60)
        let safeYRange = (60...screenSize.height - 60)
        
        let newPosition = CGPoint(
            x: CGFloat.random(in: safeXRange),
            y: CGFloat.random(in: safeYRange)
        )
        
        let newRotation = Angle.degrees(Double.random(in: -30...30))
        let newScale = CGFloat.random(in: 0.9...1.1)
        let duration = Double.random(in: 7...12)
        
        withAnimation(.easeInOut(duration: duration)) {
            self.position = newPosition
            self.rotation = newRotation
            self.scale = newScale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            startFloating(screenSize: screenSize)
        }
    }
    
    private func animateThrow(screenSize: CGSize) {
        // Timer-driven animation loop to continuously update moon's position and velocity
        let throwDuration = 0.02 // smooth updates

        Timer.scheduledTimer(withTimeInterval: throwDuration, repeats: true) { timer in
            // Update position based on velocity
            position.x += velocity.width * CGFloat(throwDuration * 60)
            position.y += velocity.height * CGFloat(throwDuration * 60)

            // Detect collisions with screen edges and bounce by reversing velocity
            if position.x < 60 || position.x > screenSize.width - 60 {
                velocity.width *= -0.8
                position.x = min(max(position.x, 60), screenSize.width - 60)
            }

            if position.y < 60 || position.y > screenSize.height - 60 {
                velocity.height *= -0.8
                position.y = min(max(position.y, 60), screenSize.height - 60)
            }

            // Apply gradual friction to slow the moon over time
            velocity.width *= 0.92
            velocity.height *= 0.92

            // Stop motion once velocity is low enough and resume gentle floating motion
            if abs(velocity.width) < 0.1 && abs(velocity.height) < 0.1 {
                timer.invalidate()
                velocity = .zero
                // Reset thrown state once motion slows and resume floating + eye animation
                isThrown = false
                startFloating(screenSize: screenSize)
            }
        }
    }
}

//struct MoonFaceView: View {
//    var isThrown: Bool
//    // Shared pupil movement to keep both eyes synced and prevent cross-eyed motion
//    @State private var sharedPupilOffset: CGSize = .zero
//
//    var body: some View {
//        VStack(spacing: 8) {
//            // Eyes
//            HStack(spacing: 20) {
//                // Both eyes use the same pupil offset for synchronized movement
//                GooglyEyeView(pupilOffset: sharedPupilOffset).frame(width: 25, height: 25)
//                // Both eyes use the same pupil offset for synchronized movement
//                GooglyEyeView(pupilOffset: sharedPupilOffset).frame(width: 25, height: 25)
//            }
//
//            // Mouth
//            Path { path in
//                path.move(to: CGPoint(x: 0, y: 2))
//                path.addQuadCurve(to: CGPoint(x: 45, y: 5), control: CGPoint(x: 25, y: 25))
//            }
//            .stroke(Color.black.opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .round))
//            .frame(width: 40, height: 15)
//        }
//        .offset(y: 8)
//        .onAppear {
//            // Periodically animate both pupils unless moon is being thrown
//            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
//                if !isThrown {
//                    withAnimation(.easeInOut(duration: 1)) {
//                        sharedPupilOffset = CGSize(width: Double.random(in: -4...4), height: Double.random(in: -4...4))
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct GooglyEyeView: View {
//    var pupilOffset: CGSize
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(Color.white)
//                .shadow(radius: 1)
//            
//            Circle()
//                .fill(Color.black)
//                .scaleEffect(0.5)
//                .offset(pupilOffset)
//            
//            Circle()
//                .fill(Color.white)
//                .scaleEffect(0.2)
//                .offset(x: -1.5 + pupilOffset.width, y: -1 + pupilOffset.height)
//        }
//    }
//}

#Preview {
    MoonView()
}
