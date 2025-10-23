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
    
    let sampleDream: DreamModel = .init(userID: "6gOZw9yW4DYIeM2rnWe5AEGgoJm2", id: "6gOZw9yW4DYIeM2rnWe5AEGgoJm3", title: "A Haunted Building", date: Date(), loggedContent: "I was standing outside and I looked at the house I was staying in. Of all the rooms mine was the only one that had these lantern looking lights on outside. I was so confused. I tried sleeping that night but the lights were so bright.", generatedContent: "gen content", tags: [.animals, .forests], image: "image", emotion: .fear)
    
    var body: some View {
        Button(action: {
            Task {
                await fds.createDream(dream: sampleDream)
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
