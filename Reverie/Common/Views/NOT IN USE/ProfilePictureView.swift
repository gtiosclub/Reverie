//
//  ProfilePictureView.swift
//  Reverie
//
//  Created by Divya Mathew on 9/18/25.
//

import SwiftUI

struct ProfilePictureView: View {
    var size: CGFloat = 96
    
    var body: some View {
        ZStack{
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.white)
            
        }
        .frame(maxWidth: 48, maxHeight: 48)
        .clipShape(Circle())
        .accessibilityLabel("Profile picture")

    }
}

#Preview {
    ProfilePictureView()
        .background(BackgroundView())
}
