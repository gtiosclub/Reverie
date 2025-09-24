//
//  TrendingView.swift
//  Reverie
//
//  Created by Zhihui Chen on 9/23/25.
//

import SwiftUI

struct TrendingView: View {
    var titles = ["Title1", "Title2","Title3"]
    var categories = ["Category1", "Category2","Category3"]
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(alignment: .leading) {
                Text("Trending This Week")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                ForEach(titles.indices, id: \.self) { index in
                    HStack {
                        Text("\(index + 1)")
                            .font(.title)
                            .bold()
                            .italic()
                            .foregroundColor(Color(red: 0.9, green: 0.35, blue: 0.9))
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(titles[index])
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(categories[index])
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .padding(.horizontal, 3)
                .padding(.vertical,3)
            }
            .padding()
        }
    }
}

#Preview {
    TrendingView()
}

