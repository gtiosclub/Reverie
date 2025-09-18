//
//  LoggingView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct LoggingView: View {
    var body: some View {
        ZStack {
            VStack {
                Text("reverie is now logging")
            }
            TabbarView()
        }
    }
}

#Preview {
    LoggingView()
}
