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

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)
                    .opacity(0.35)

                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(white: 0.95), Color(white: 0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                MoonFaceView()
            }
            .rotationEffect(rotation)
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                self.position = CGPoint(x: geometry.size.width / 4, y: geometry.size.height / 4)
                startFloating(screenSize: geometry.size)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    
    private func startFloating(screenSize: CGSize) {
        let safeXRange = (0...screenSize.width)
        let safeYRange = (0...screenSize.height)
        
        let newPosition = CGPoint(
            x: CGFloat.random(in: safeXRange),
            y: CGFloat.random(in: safeYRange)
        )
        
        let newRotation = Angle.degrees(Double.random(in: -30...30))
        let newScale = CGFloat.random(in: 0.9...1.1)
        let duration = Double.random(in: 15...25)
        
        withAnimation(.easeInOut(duration: duration)) {
            self.position = newPosition
            self.rotation = newRotation
            self.scale = newScale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            startFloating(screenSize: screenSize)
        }
    }
}

struct MoonFaceView: View {
    var pupilOffset: CGSize = CGSize(width: Double.random(in: -4...4), height: Double.random(in: -4...4))
    
    var body: some View {
        VStack(spacing: 8) {
            // Eyes
            HStack(spacing: 20) {
                GooglyEyeView(pupilOffset: pupilOffset).frame(width: 25, height: 25)
                GooglyEyeView(pupilOffset: pupilOffset).frame(width: 25, height: 25)
            }
            
            // Mouth
            Path { path in
                path.move(to: CGPoint(x: 0, y: 2))
                path.addQuadCurve(to: CGPoint(x: 45, y: 5), control: CGPoint(x: 25, y: 25))
            }
            .stroke(Color.black.opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: 40, height: 15)
        }
        .offset(y: 8)
    }
}

struct GooglyEyeView: View {
    var pupilOffset: CGSize
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .shadow(radius: 1)
            
            Circle()
                .fill(Color.black)
                .scaleEffect(0.5)
                .offset(pupilOffset)
            
            Circle()
                .fill(Color.white)
                .scaleEffect(0.2)
                .offset(x: -1.5 + pupilOffset.width, y: -1 + pupilOffset.height)
        }
    }
}

#Preview {
    MoonView()
}
