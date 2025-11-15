// Theme.swift

import SwiftUI

enum Theme {
    static let bg        = Color(hex: 0x0E0B1E)
    static let card      = Color(hex: 0x141127)
    static let cardHi    = Color(hex: 0x1B1731)
    static let pill      = Color(hex: 0x2A2349)
    static let accent    = Color(hex: 0xB6A7FF)
    static let gridLine  = Color.white.opacity(0.06)

    static let awake     = Color(hex: 0xFF9B4A)
    static let rem       = Color(hex: 0xC86CFF)
    static let light     = Color(hex: 0x4ED1FF)
    static let deep      = Color(hex: 0x3BD079)
}

extension Color {
    /// Allow Color(hex: 0xRRGGBB)
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double(hex & 0xFF)        / 255,
            opacity: alpha
        )
    }
}
