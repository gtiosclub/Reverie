//
//  DreamFetchTest.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/30/25.
//

import SwiftUI

// Test for pulling in dream information
// Need to set ReverieApp to this view in order to test!!!
struct DreamFetchTest: View {
    @Environment(FirebaseDreamService.self) private var fds
    @State private var dreams: [DreamModel] = []
    
    var body: some View {
        Button(action: {
            Task {
                dreams = try await fds.getDreams()
            }
        }) {
            Text("Fetch Dreams")
        }
        if !dreams.isEmpty {
            ForEach(dreams, id: \.id) { dream in
                Text(dream.loggedContent)
                    .foregroundStyle(.white)
            }
        } else {
            Text("You have no dreams")
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    DreamFetchTest()
        .environment(FirebaseDreamService.shared)
}
