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
                StartView()
            case .archive:
                DreamArchiveView()
            case .analytics:
                AnalysisView()
            default: LoggingView()
            }

            VStack {
                Spacer()
                TabbarView()
            }
        }
    }
}
