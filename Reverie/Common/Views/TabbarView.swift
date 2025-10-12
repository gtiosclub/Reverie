//
//  TabbarFloating.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/18/25.
//

import SwiftUI

struct TabbarView: View {
    var body: some View {
//        VStack {
            HStack {
                TabButton(title: Image(systemName: "house"), destination: StartView())
                TabButton(title: Image(systemName: "chart.bar"), destination: ProfileView())
                TabButton(title: Image(systemName: "doc.text"), destination: LoggingView()) // placeholder
            }
            .padding()
            .frame(maxWidth: 300, maxHeight: 50)
            .glassEffect(.regular, in: .rect)
            .cornerRadius(20)
//        }
//        .frame(maxHeight: .infinity, alignment: .bottom)
//        .padding(.bottom, -10)
    }
}

// Tab Buttons
struct TabButton<Destination: View>: View {
    let title: Image
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            title
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 18))
                .foregroundColor(.gray)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TabbarView()
        .background(BackgroundView())
}
