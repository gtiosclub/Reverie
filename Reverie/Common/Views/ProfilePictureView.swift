//
//  ProfilePictureView.swift
//  Reverie
//
//  Created by Divya Mathew on 9/18/25.
//

import SwiftUI

struct ProfilePictureView: View {
    var image: Image?
    var size: CGFloat = 96
    
    var body: some View {
        ZStack{
            
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .padding(size * 0.12)
            
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityLabel("Profile picture")

    }
}

#Preview {
    ProfilePictureView()
}
