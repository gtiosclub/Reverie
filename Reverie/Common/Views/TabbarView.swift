//
//  TabbarFloating.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/18/25.
//

import SwiftUI


struct TabbarView: View {
    @EnvironmentObject var ts: TabState

    var body: some View {
//        VStack {
            HStack {
                TabButton(title: Image(systemName: "house"), tab: .home, destination: StartView())
                TabButton(title: Image(systemName: "chart.bar"), tab: .analytics, destination: ProfileView())
                TabButton(title: Image(systemName: "doc.text"), tab: .archive, destination: DreamArchiveView())
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
    let tab: TabType
    let destination: Destination
    
    @EnvironmentObject var ts: TabState
    
    var body: some View {
        NavigationLink(destination: destination
            .onAppear {
                ts.activeTab = tab
            }) {
            title
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 18))
                .foregroundColor(ts.activeTab == tab ? Color.purple.opacity(0.6) : .gray)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TabbarView()
        .background(BackgroundView())
        .environmentObject(TabState())
}
