//
//  DreamCardProgressView.swift
//  Reverie
//
//  Created by Zhihui Chen on 09/29/25.
//

import SwiftUI

struct DreamCardProgressView: View {
    var progress: Float
    @State private var glow = false
    @State private var animate = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                )
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors:[Color.purple, Color.pink,Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(Double(progress))
                .shadow(
                    color: progress >= 1.0 ? Color.purple.opacity(animate ? 0.8 : 0.3): .clear,
                    radius: animate ? 50 : 15
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                        animate.toggle()
                    }
                }

            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(progress >= 1.0 ? .yellow : .white)
                .scaleEffect(progress >= 1.0 ? 1.2 : 1.0)
        }
        .frame(width: 200, height: 300)
        .padding()
        .onChange(of: progress) { _, newValue in
            if newValue >= 1.0 {
                glow = true
            }
        }
    }
}
#Preview {
    DreamCardProgressView(progress: 0.75)
}
