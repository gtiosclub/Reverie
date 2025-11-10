//
//  DreamGlow.swift
//  Reverie
//
//  Created by amber verma on 11/10/25.
//

import SwiftUI

struct DreamGlow: ViewModifier {
    private let glowColor = Color(red: 150/255, green: 70/255, blue: 255/255)

    func body(content: Content) -> some View {
        content
            .shadow(color: glowColor.opacity(0.6), radius: 3)
            .shadow(color: glowColor.opacity(0.45), radius: 8)
            .shadow(color: glowColor.opacity(0.3), radius: 16)
            .shadow(color: glowColor.opacity(0.15), radius: 28)
    }
}

extension View {
    func dreamGlow() -> some View {
        modifier(DreamGlow())
    }
}
