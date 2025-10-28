//
//  DreamCardProgressView.swift
//  Reverie
//
//  Created by Zhihui Chen on 09/29/25.
//

import SwiftUI

struct DreamCardProgressView: View {
    var progress: Float
    @State private var animate = false

    private var imageName: String {
        switch progress {
        case 0..<0.2:
            return "pack1"
        case 0.2..<0.4:
            return "pack2"
        case 0.4..<0.6:
            return "pack3"
        case 0.6..<0.99:
            return "pack4"
        default:
            return "pack5"
        }
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 300)
            .shadow(
                color: progress >= 1.0
                    ? Color.purple.opacity(animate ? 0.8 : 0.3)
                    : .clear,
                radius: animate ? 50 : 15
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
            .padding()
    }
}

#Preview {
    DreamCardProgressView(progress: 1.0)
}

