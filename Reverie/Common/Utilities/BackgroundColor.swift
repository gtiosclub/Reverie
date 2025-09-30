//
//  BackgroundColor.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/24/25.
//

import SwiftUI

struct BackgroundColor: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.1, blue: 0.2),
                Color(red: 0.05, green: 0.05, blue: 0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    BackgroundColor()
}
