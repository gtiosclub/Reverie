//
//  StatView.swift
//  Reverie
//
//  Created by Isha Jain on 10/9/25.
//

import SwiftUI

struct StatView: View {
    
    let stat: Int
    let title: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.gray, .black]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 130
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text("\(stat)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white)
                
            }
            Text(title)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 140)
                .foregroundStyle(.white)
                .bold()
            
        }
    }
}

#Preview {
    StatView(stat: 7, title: "Dreams Logged").background(BackgroundView())
}
