//
//  NewsView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct NewsView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                Text("reverie news")
                    .foregroundColor(Color(.white))
            }
            TabbarView()
        }
    }
}

#Preview {
    NewsView()
}
