//
//  StarsView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/14/25.
//

import SwiftUI

struct Star: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speedX: CGFloat
    let speedY: CGFloat
    var brightness: CGFloat
}

struct StarsView: View {
    @State private var stars: [Star] = []
    let starCount = 80
    @State private var timer: Timer? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                ForEach(stars.indices, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: stars[i].size, height: stars[i].size)
                        .position(x: stars[i].x, y: stars[i].y)
                }
            }
            .onAppear {
                // When screen is loaded add stars
                DispatchQueue.main.async {
                    if stars.isEmpty {
                        for _ in 0..<starCount {
                            let size = CGFloat.random(in: 1...3)
                            let x = CGFloat.random(in: 0...geometry.size.width)
                            let y = CGFloat.random(in: 0...geometry.size.height)
                            let speedX = CGFloat.random(in: -20...20) // negative = left, positive = right
                            let speedY = CGFloat.random(in: -20...20) // negative = up, positive = down
                            let brightness = CGFloat.random(in: 0.3...0.8)
                            stars.append(Star(x: x, y: y, size: size, speedX: speedX, speedY: speedY, brightness: brightness))
                        }
                    }
                }
                
                if timer == nil {
                    //Every .05 seconds update star location
                    timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                        for i in stars.indices {
                            stars[i].x += stars[i].speedX * 0.05
                            stars[i].y += stars[i].speedY * 0.05
                            stars[i].brightness *= CGFloat.random(in: 0.8...1.2)
                            
                            // Wrap Star around screen horizontally
                            if stars[i].x > geometry.size.width + stars[i].size {
                                stars[i].x = -stars[i].size
                            } else if stars[i].x < -stars[i].size {
                                stars[i].x = geometry.size.width + stars[i].size
                            }
                            
                            // Wrap Star around screen vertically
                            if stars[i].y > geometry.size.height - stars[i].size {
                                stars[i].y = -stars[i].size
                            } else if stars[i].y < -stars[i].size {
                                stars[i].y = geometry.size.height - stars[i].size
                            }
                            
                            // A star will never have brightness < 0.1
                            if stars[i].brightness < 0.1 {
                                stars[i].brightness = 0.3
                            }
                            
                            // A star will never have brightness > 1
                            if stars[i].size > 1 {
                                stars[i].brightness = 0.7
                            }
                        }
                    }
                }
            }
            .onDisappear {
                // Invalidate timer when view disappears
                timer?.invalidate()
                timer = nil
            }
        }
    }
}

#Preview {
    StarsView()
}
