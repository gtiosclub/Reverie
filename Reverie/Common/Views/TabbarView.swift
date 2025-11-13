//
//  TabbarFloating.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/18/25.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: some View { build() }
}

struct TabbarView: View {
    @EnvironmentObject var ts: TabState

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabButton(
                    title: Image(systemName: "house"),
                    text: "Home",
                    tab: .home,
                    destination: LazyView(StartView())
                )

                TabButton(
                    title: Image(systemName: "star.fill"),
                    text: "Archive",
                    tab: .archive,
                    destination: LazyView(DreamArchiveView())
                )

                TabButton(
                    title: Image(systemName: "chart.bar"),
                    text: "Analysis",
                    tab: .analytics,
                    destination: LazyView(AnalysisView())
                )
            }
            .frame(maxWidth: 300, maxHeight: 60)
            .glassEffect(.regular)
            .background(Color.black.opacity(0.5))
            .cornerRadius(100)
            .padding(.bottom, -10)
        }
    }
}

struct TabButton<Destination: View>: View {
    let title: Image
    let text: String
    let tab: TabType
    let destination: Destination

    @EnvironmentObject var ts: TabState

    var body: some View {
        NavigationLink(destination: destination) {
            VStack {
                if title == Image(systemName: "star.fill") {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(lineWidth: 1.5)
                            .frame(width: 18, height: 18)

                        title
                            .font(.system(size: 12))
                    }
                    .padding(.bottom, -4)
                } else {
                    title
                }

                Text(text)
                    .font(.footnote)
            }
            .foregroundColor(ts.activeTab == tab ? .indigo.opacity(0.6) : .gray)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .simultaneousGesture(TapGesture().onEnded {
            ts.activeTab = tab
        })
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        TabbarView()
            .background(BackgroundView())
            .environmentObject(TabState())
    }
}

