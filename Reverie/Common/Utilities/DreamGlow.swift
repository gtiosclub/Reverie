//
//  DreamGlow.swift
//  Reverie
//
//  Created by amber verma on 11/10/25.
//

import SwiftUI

struct DreamGlow: ViewModifier {
    private let glowColor = Color(red: 110/255, green: 70/255, blue: 255/255) // Violet tone

    func body(content: Content) -> some View {
        content
            // Step 1: small bright core
            .shadow(color: glowColor.opacity(0.6), radius: 6)
            // Step 2: medium blur ring
            .shadow(color: glowColor.opacity(0.35), radius: 18)
            // Step 3: outer soft aura
            .shadow(color: glowColor.opacity(0.25), radius: 42)
            // Step 4: far diffuse glow for space feel
            .shadow(color: glowColor.opacity(0.15), radius: 84)
    }
}

extension View {
    func dreamGlow() -> some View {
        modifier(DreamGlow())
    }
}
