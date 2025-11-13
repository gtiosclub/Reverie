//
//  ThisWeekThemesView.swift
//  Reverie
//
//  Created by Isha Jain on 11/8/25.
//

import SwiftUI

struct ThisWeekThemesView: View {
    let thisWeekTags: [DreamModel.Tags]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text("Your most common dream themes are ")
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Image(systemName: "chevron.right")
//                    .font(.callout.weight(.semibold))
                    .foregroundColor(.gray)
//                    .padding(.top, -8)
                    .font(Font.system(size: 14))
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 3)

            if thisWeekTags.isEmpty {
                VStack {
                    Spacer()
                    Text("No tags for this week")
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                TagViewBlock(title: "", tags: thisWeekTags, isExpandable: false, limitToFirstRow: true)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.profileContainer)
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

#Preview {
    ThisWeekThemesView(thisWeekTags: findMostCommonTags(dreams: [d1, d2]))
}
