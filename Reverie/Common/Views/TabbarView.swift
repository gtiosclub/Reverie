//
//  TabbarView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/14/25.
//

import SwiftUI

struct TabbarView: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray)
            
            HStack {
                TabButton(title: "Log", destination: LoggingView())
                TabButton(title: "Profile", destination: ProfileView())
                TabButton(title: "Analytics", destination: ProfileView()) // placeholder
                TabButton(title: "News", destination: NewsView())
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, -10)
    }
}

// Tab Buttons
struct TabButton<Destination: View>: View {
    let title: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    TabbarView()
}
