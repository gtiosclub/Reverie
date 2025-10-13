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
                .font(.headline)
                .lineLimit(1)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity)
           
            Image(systemName: DreamModel.getTagImage(tag: tagGiven))
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
        }
        .padding()
        //change hardcoded values
        .frame(width: 100, height: 170)
        .background(Color(.darkGray))
        .cornerRadius(25)
    }
}

#Preview {
    TagView(tagGiven: .school)
}
