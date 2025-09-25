//
//  NewsCardView.swift
//  Reverie
//
//  Created by Jacoby Melton on 9/25/25.
//

import SwiftUI


struct NewsCardView: View {
    let title: String
    let image_string: String
    let viewDim : CGFloat = 300
    let bookmarked = false
    var body: some View {
        
        ZStack (alignment: .topTrailing) {
            VStack (spacing: 0) {
                Image(image_string)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: viewDim, height: viewDim - viewDim / 4)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 20
                        )
                    )
                
                HStack {
                    Text(title)
                        .font(.headline)
                        .padding()

                    Spacer()

                    Button {
                        // add more button functionality
                    } label : {
                        Image(systemName: "chevron.forward.circle.fill")
                            .resizable()
                            .frame(width: viewDim / 10, height: viewDim / 10)
                    }
                    .padding(10)
                    .foregroundColor(.gray.opacity(0.5))


                }
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 0
                    ).fill(Color.gray.opacity(0.4))
                        .frame(width: viewDim, height: viewDim / 4)
                )
                .frame(width: viewDim, height: viewDim / 4)
            }
            
            Button {
                // add bookmarking functionality
            } label : {
                Image(systemName: bookmarked ? "bookmark.fill" : "bookmark")
                    .resizable()
                    .frame(width: viewDim / 10, height: viewDim / 8)
                    .foregroundColor(.white)
            }
            .padding(10)
        }
        .frame(width: viewDim, height: viewDim)
        
        
    }
    
}

#Preview {
    NewsCardView(title: "Article title for dream news card view", image_string: "AIFly")
}
