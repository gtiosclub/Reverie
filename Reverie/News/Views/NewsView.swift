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
                HStack {
                    Text("Dream News")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                        .bold()
                        .padding(.leading, 16)
                    Spacer()
                    ProfilePictureView()
                        .padding(.trailing, 16)
                }
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            TabbarView()
        }
    }
}

#Preview {
    NewsView()
}
