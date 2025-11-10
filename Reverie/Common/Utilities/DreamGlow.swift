//
//  DreamGlow.swift
//  Reverie
//
//  Created by amber verma on 11/10/25.
//

import SwiftUI

struct DreamGlow: ViewModifier {
    private let glowColor = Color(red: 45/255, green: 32/255, blue: 86/255)
    
    func body (content: Content) -> some View {
        content
            .shadow(color: glowColor.opacity(1.0), radius: 8)
            .shadow(color: glowColor.opacity(0.9), radius: 16)
            .shadow(color: glowColor.opacity(0.8), radius: 32)
            .shadow(color: glowColor.opacity(0.6), radius: 48)
    }
}

extension View {
    func dreamGlow() -> some View {
        modifier(DreamGlow())
    }
}
