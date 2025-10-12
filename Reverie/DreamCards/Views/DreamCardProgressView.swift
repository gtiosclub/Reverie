//
//  DreamCardProgressView.swift
//  Reverie
//
//  Created by Zhihui Chen on 09/29/25.
//

import SwiftUI

struct DreamCardProgressView: View {
    let progress: Float
    
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )

                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors:[.purple, .pink, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: geometry.size.height * CGFloat(progress))
                    .shadow(
                        color: progress >= 1.0 ? Color.purple.opacity(animate ? 0.8 : 0.3): .clear,
                        radius: animate ? 50 : 15
                    )
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(progress >= 1.0 ? .yellow : .white)
                    .scaleEffect(progress >= 1.0 ? 1.2 : 1.0)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .frame(width: 200, height: 300)
        .padding()
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                animate.toggle()
            }
        }
    }
}

#Preview {
    DreamCardProgressView(progress: 0.75)
}
