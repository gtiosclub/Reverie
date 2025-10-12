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
        VStack (spacing: 20) {
            Text(String(describing: tagGiven).capitalized)
                .font(.largeTitle)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.8)
           
            Image(systemName: DreamModel.getTagImage(tag: tagGiven))
                .resizable()
                .scaledToFit()
                .scaleEffect(0.5)
                .foregroundColor(.white)
        }
        .padding()
        //change hardcoded values
        .frame(width: 300, height: 639)
        .background(Color(.darkGray))
        .cornerRadius(50)
    }
}

#Preview {
    TagView(tagGiven: .school)
}
