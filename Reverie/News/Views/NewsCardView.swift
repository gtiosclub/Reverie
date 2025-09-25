//
//  NewsCardView.swift
//  Reverie
//
//  Created by Jacoby Melton on 9/25/25.
//

import SwiftUI


struct NewsCardView: View {
    let title: String
    let description: String
    let viewDim : CGFloat = 300
    var body: some View {
        
        ZStack (alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.47, green: 0.2, blue: 0.97, opacity: 0.4))
                .stroke(
                    LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            VStack (alignment: .leading) {
                Text("Daily Insight")
                    .font(.custom("baskerville-bold", size: 15))
                    .foregroundColor(.purple)
                
                Image(systemName: "key.fill")
                    .resizable()
                    .frame(width: viewDim / 13, height: viewDim / 7)
                    .padding(10)
                    .foregroundColor(.white)
                    .shadow(color: Color(red: 0.7, green: 0.2, blue: 0.8, opacity: 1.0), radius: 10)
                Text(title)
                    .font(.custom("baskerville-bold", size: 25))
                    .foregroundColor(.white)
                    .padding(.bottom, 5)
                
                Text(description)
                    .font(.custom("baskerville-semibold", size: 18))
                    .foregroundColor(.gray)
                    
                    
            }
            .padding(25)
        }
        .frame(width: viewDim, height: viewDim)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .fill(.black)
                .shadow(color: Color(red: 0.7, green: 0.2, blue: 0.8, opacity: 0.7), radius: 10)
                
        )
        .frame(width: viewDim, height: viewDim)
        
        
    }
    
}

#Preview {
    NewsCardView(title: "Example Daily Inisght Title", description: "Example description of daily insight article.")
}
