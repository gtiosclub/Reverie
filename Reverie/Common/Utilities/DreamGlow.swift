//
//  DreamGlow.swift
//  Reverie
//
//  Created by amber verma on 11/10/25.
//

import SwiftUI

struct DreamGlow: ViewModifier {
    private let glowColor = Color(red: 45/255, green: 32/255, blue: 86/255)

    func body(content: Content) -> some View {
        content
            .shadow(color: glowColor.opacity(0.25), radius: 18)
            .shadow(color: glowColor.opacity(0.18), radius: 36)
            .shadow(color: glowColor.opacity(0.12), radius: 64)
            .shadow(color: glowColor.opacity(0.08), radius: 96)
    }
}

extension View {
    func dreamGlow() -> some View {
        modifier(DreamGlow())
    }
}
