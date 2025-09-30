//
//  BackgroundView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/23/25.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            BackgroundColor()
            StarsView()
        }
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    BackgroundView()
}
