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
        HStack (spacing: 0){
            TabButton(title: Image(systemName: "house"), text: "Home", tab: .home, destination: StartView())
            TabButton(title: Image(systemName: "chart.bar"), text: "Analysis", tab: .analytics, destination: ProfileView())
            TabButton(title: Image(systemName: "doc.text"), text: "Archive", tab: .archive, destination: DreamArchiveView())
            }
//            .padding()
            .frame(maxWidth: 300, maxHeight: 50)
            .glassEffect(.regular)
//            .glassEffect(.regular, in: .rect)
            .cornerRadius(20)
//        }
//        .frame(maxHeight: .infinity, alignment: .bottom)
//        .padding(.bottom, -10)
    }
}

// Tab Buttons
struct TabButton<Destination: View>: View {
    let title: Image
    let text: String
    let tab: TabType
    let destination: Destination
    
    @EnvironmentObject var ts: TabState
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack {
                title
                Text(text)
                    .font(.footnote).textScale(.secondary)
            }
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 18))
                .foregroundColor(ts.activeTab == tab ? Color.indigo.opacity(0.6) : .gray)
        }
        .simultaneousGesture(TapGesture().onEnded{
            ts.activeTab = tab
        })
        .navigationBarBackButtonHidden(true)
        .background(ts.activeTab == tab ?
                    Capsule()
                        .glassEffect(.regular)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 2.5)
                        .padding(.vertical, 12)
                        .opacity(0.3)
                        .cornerRadius(20)
                    : nil)
    }
}

#Preview {
    TabbarView()
        .background(BackgroundView())
        .environmentObject(TabState())
}
