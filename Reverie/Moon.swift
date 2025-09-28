//
//  Moon.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/23/25.
//

import SwiftUI

// MARK: - Main View to Host the Moon
// This is an example of how you'd include the moon in your home screen ZStack.
struct MoonHostingView: View {
    var body: some View {
        ZStack {
            // Your other home screen content
            Color(red: 0.1, green: 0.0, blue: 0.2).ignoresSafeArea()
            FloatingRocketView()
            SillyMoonView()
            Text("Your Home Screen Content")
                .font(.largeTitle)
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

// MARK: - The Updated Silly Moon View
struct SillyMoonView: View {
    @State private var position: CGPoint = .zero
    @State private var rotation: Angle = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Outer glow for a more celestial look
                Circle()
                    .fill(Color.white)
                    .frame(width: 150, height: 150)
                    .blur(radius: 30)
                    .opacity(0.5)

                // Main moon body with a subtle gray gradient for depth
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(white: 0.9), Color(white: 0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                
                // Craters for a more realistic moon texture
                MoonCratersView()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .opacity(0.2)
                
                // The new, more detailed face
                SillyFaceView()
            }
            .rotationEffect(rotation)
            .position(position)
            .onAppear {
                self.position = CGPoint(x: -100, y: geometry.size.height * 0.2)
                startLurking(screenSize: geometry.size)
            }
        }
        .ignoresSafeArea()
    }
    
    // The animation logic remains the same
    private func startLurking(screenSize: CGSize) {
        let screenBounds = CGRect(x: -150, y: -150, width: screenSize.width + 300, height: screenSize.height + 300)
        let newPosition = CGPoint(x: CGFloat.random(in: screenBounds.minX...screenBounds.maxX), y: CGFloat.random(in: screenBounds.minY...screenBounds.maxY))
        let newRotation = Angle.degrees(Double.random(in: -15...15))
        let duration = Double.random(in: 8...15)
        
        withAnimation(.easeInOut(duration: duration)) {
            self.position = newPosition
            self.rotation = newRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            startLurking(screenSize: screenSize)
        }
    }
}

// MARK: - New Subviews for Moon Details

// A view to draw the craters on the moon's surface
struct MoonCratersView: View {
    var body: some View {
        ZStack {
            Circle().stroke().scaleEffect(0.2).position(x: 40, y: 50)
            Circle().stroke().scaleEffect(0.15).position(x: 100, y: 110)
            Circle().stroke().scaleEffect(0.1).position(x: 120, y: 40)
            Circle().stroke().scaleEffect(0.08).position(x: 75, y: 100)
            Circle().stroke().scaleEffect(0.12).position(x: 60, y: 125)
        }
        .foregroundColor(Color.black.opacity(0.5))
    }
}


// A view for the detailed, silly face
struct SillyFaceView: View {
    var body: some View {
        VStack(spacing: 12) {
            // Eyes
            HStack(spacing: 25) {
                GooglyEyeView().frame(width: 30, height: 30)
                GooglyEyeView().frame(width: 25, height: 25) // Asymmetrical for silliness
            }
            
            // Mouth
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 50, y: 10), control: CGPoint(x: 25, y: 30))
            }
            .stroke(Color.black.opacity(0.8), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .frame(width: 50, height: 20)
        }
        .offset(y: 10)
    }
}

// A reusable view for a single googly eye
struct GooglyEyeView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .shadow(radius: 2)
            
            Circle()
                .fill(Color.black)
                .scaleEffect(0.6)
            
            Circle()
                .fill(Color.white)
                .scaleEffect(0.25)
                .offset(x: -3, y: -2)
        }
    }
}

// MARK: - SwiftUI Preview
struct SillyMoonView_Previews: PreviewProvider {
    static var previews: some View {
        MoonHostingView()
    }
}

// MARK: - Data Model for a Smoke Bubble
struct SmokeBubble: Identifiable {
    let id = UUID()
}

import Combine

// MARK: - The Floating Rocket View
struct FloatingRocketView: View {
    @State private var position: CGPoint = .zero
    @State private var rotation: Angle = .zero
    @State private var smokeBubbles: [SmokeBubble] = []
    
    // Timer to generate smoke bubbles
    private let smokeTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Smoke Bubble Trail
                ForEach(smokeBubbles) { bubble in
                    BubbleView()
                        .position(calculateBubbleStartPosition())
                }
                
                // Rocket Body
                RocketBodyView()
                    .rotationEffect(.degrees(90)) // Point the rocket up initially
                    .rotationEffect(rotation)
                    .position(position)
            }
            .onAppear {
                // Set initial off-screen position and start flying
                self.position = CGPoint(x: geometry.size.width + 100, y: geometry.size.height * 0.5)
                startFlying(screenSize: geometry.size)
            }
            .onReceive(smokeTimer) { _ in
                // Add a new bubble
                smokeBubbles.append(SmokeBubble())
                
                // Keep the array from growing too large
                if smokeBubbles.count > 25 {
                    smokeBubbles.removeFirst()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Animation Logic
    private func startFlying(screenSize: CGSize) {
        let screenBounds = CGRect(x: -150, y: -150, width: screenSize.width + 300, height: screenSize.height + 300)
        
        let newPosition = CGPoint(x: CGFloat.random(in: screenBounds.minX...screenBounds.maxX), y: CGFloat.random(in: screenBounds.minY...screenBounds.maxY))
        let duration = Double.random(in: 6...12)
        
        // Calculate the angle to point towards the new destination
        let deltaX = newPosition.x - self.position.x
        let deltaY = newPosition.y - self.position.y
        let angle = atan2(deltaY, deltaX)
        let newRotation = Angle(radians: Double(angle))
        
        withAnimation(.easeInOut(duration: duration)) {
            self.position = newPosition
            self.rotation = newRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            startFlying(screenSize: screenSize)
        }
    }
    
    private func calculateBubbleStartPosition() -> CGPoint {
        // Calculate the position for new bubbles at the base of the rocket
        let angle = rotation.radians
        let radius: CGFloat = -60 // Distance from the center of the rocket
        let x = position.x + radius * cos(CGFloat(angle))
        let y = position.y + radius * sin(CGFloat(angle))
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Rocket & Bubble Subviews
struct RocketBodyView: View {
    @State private var flameFlicker = false
    
    var body: some View {
        ZStack {
            // Fins
            Triangle()
                .fill(Color.red)
                .frame(width: 50, height: 60)
                .offset(x: 0, y: 35)
            
            // Main Body
            Capsule()
                .fill(LinearGradient(colors: [.white, .gray], startPoint: .top, endPoint: .bottom))
                .frame(width: 80, height: 150)
                .shadow(radius: 5)
            
            // Window
            Circle()
                .fill(
                    RadialGradient(colors: [.blue.opacity(0.3), .blue], center: .center, startRadius: 5, endRadius: 20)
                )
                .frame(width: 40, height: 40)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .offset(y: -30)
            
            // Flame
            Triangle()
                .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                .frame(width: 40, height: flameFlicker ? 60 : 50)
                .offset(y: 90)
                .blur(radius: 5)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.1).repeatForever()) {
                flameFlicker.toggle()
            }
        }
    }
}

struct BubbleView: View {
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: 30, height: 30)
            .scaleEffect(scale)
            .onAppear {
                let randomDelay = Double.random(in: 0...0.5)
                withAnimation(.easeOut(duration: 2).delay(randomDelay)) {
                    scale = Double.random(in: 1.0...1.5)
                    opacity = 0.0
                }
            }
    }
}


// MARK: - Reusable Supporting Views
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


