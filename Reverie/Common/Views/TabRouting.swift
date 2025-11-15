//
//  TabRouting.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/15/25.
//

import SwiftUI

struct TabRouting: View {
    @EnvironmentObject var ts: TabState
    @State private var showLogging = false

    var body: some View {
        ZStack {
            switch ts.activeTab {
            case .home:
                StartView(showLogging: $showLogging)
            case .archive:
                DreamArchiveView()
            case .analytics:
                AnalysisView()
            default: LoggingView()
            }
            
            if showLogging {
                LoggingView()
                    .transition(.opacity)
                    .zIndex(1)
            }

            VStack {
                Spacer()
                TabbarView()
            }
        }
        .onChange(of: ts.activeTab) { _ in
            showLogging = false
        }
    }
}
