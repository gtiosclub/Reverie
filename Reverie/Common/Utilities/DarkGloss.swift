//
//  GlossyColor.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/14/25.
//

import SwiftUI

struct DarkGloss: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.7),
                                Color.white.opacity(0.01)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(
                                AngularGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.9), location: 0.15),
                                        .init(color: Color.white.opacity(0.1), location: 0.35),
                                        .init(color: Color.white.opacity(0.9), location: 0.65),
                                        .init(color: Color.white.opacity(0.05), location: 0.85),
                                        .init(color: Color.white.opacity(0.7), location: 1.00)
                                    ]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360)
                                ),
                                lineWidth: 0.3
                            )
                            .blendMode(.screen)
                    )
                    .shadow(color: Color.white.opacity(0.1), radius: 12, x: 0, y: 0)
                
                    .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 6)
                
            )
            .padding(.horizontal, 20)
    }
}

extension View {
    func darkGloss() -> some View {
        modifier(DarkGloss())
    }
}
