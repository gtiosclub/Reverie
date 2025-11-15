//
//  DreamGlow.swift
//  Reverie
//
//  Created by amber verma on 11/10/25.
//

import SwiftUI

extension View {
    func dreamGlow() -> some View {
        self
            .shadow(color: Color(red: 140/255, green: 60/255, blue: 255/255).opacity(0.95), radius: 12)
            .shadow(color: Color(red: 140/255, green: 60/255, blue: 255/255).opacity(0.75), radius: 26)
    }
}
