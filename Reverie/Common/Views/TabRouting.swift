//
//  TabRouting.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/15/25.
//

import SwiftUI

struct TabRouting: View {
    @EnvironmentObject var ts: TabState

    var body: some View {
        ZStack {
            switch ts.activeTab {
            case .home:
                NavigationStack(path: $ts.homePath) { StartView() }
            case .archive:
                NavigationStack(path: $ts.archivePath) {
                    DreamArchiveView()
                        .navigationDestination(for: DreamModel.self) { dream in
                            DreamEntryView(dream: dream, backToArchive: true)
                        }
                }
            case .analytics:
                NavigationStack(path: $ts.analyticsPath) { AnalysisView() }
            default: LoggingView()
            }

            if ts.showTabBar {
                VStack {
                    Spacer()
                    TabbarView()
                }
            }
        }
    }
}
