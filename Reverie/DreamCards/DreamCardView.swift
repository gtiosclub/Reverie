//
//  DreamCardView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/23/25.
//

import SwiftUI

struct DreamCardView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                Text("Dream Cards")
                    .foregroundStyle(Color(.white))
            }
            TabbarView()
        }
    }
}

#Preview {
    DreamCardView()
}
