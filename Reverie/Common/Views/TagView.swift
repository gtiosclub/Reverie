//
//  TagView.swift
//  Reverie
//
//  Created by Isha Jain on 9/29/25.
//

import SwiftUI

struct TagView: View {
    let tagGiven: DreamModel.Tags

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(red: 11/255, green: 11/255, blue: 22/255))
                    .frame(width: 70, height: 70)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                    .glassEffect(.regular.interactive())
                    .overlay(
                        Image(systemName: DreamModel.tagImages(tag: tagGiven))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(DreamModel.tagColors(tag: tagGiven))
                        
                    )
            }

            Text(tagGiven.rawValue.capitalized)
                .foregroundStyle(.white)
                .font(.subheadline)
        }
        .frame(width: 90)
    }
}

#Preview {
    TagView(tagGiven: .school)
}
