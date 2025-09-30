//
//  DreamCardView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/23/25.
//

import SwiftUI

struct DreamCardView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                Text("Dream Cards")
                    .foregroundStyle(Color(.white))
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            TabbarView()
        }
    }
}

#Preview {
    DreamCardView()
}
