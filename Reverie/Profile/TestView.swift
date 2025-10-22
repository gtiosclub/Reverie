//
//  TestView.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/30/25.
//

import SwiftUI


struct TestView: View {
    @State private var recentDreamsOutput: [DreamModel] = []

    var body: some View {
        ZStack {
            // Simple background color instead of BackgroundView()
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Tap the button below to test getRecentDreams().")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()

                Button("Run Test: getRecentDreams()") {
                    testGetRecentDreams()
                }
                
                Button ("Emotions Dict Test"){
                    let dict = findEmotionFrequency(dreams: [d1, d2]);
                    print(dict)
                }

                if !recentDreamsOutput.isEmpty {
                    Text("Recent Dreams:")
                        .foregroundColor(.yellow)
                        .bold()
                    ForEach(recentDreamsOutput, id: \.id) { dream in
                        Text("• \(dream.title)")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
    }

    func testGetRecentDreams() {
        // Create sample dreams
        let dream1 = DreamModel(
            userID: "u1",
            id: "1",
            title: "Old Dream",
            date: Date(timeIntervalSinceNow: -86400 * 3),
            loggedContent: "Old dream content",
            generatedContent: "Generated old content",
            tags: [.mountains],
            image: "mountain.2.fill",
            emotion: .happiness
        )

        let dream2 = DreamModel(
            userID: "u1",
            id: "2",
            title: "Recent Dream",
            date: Date(timeIntervalSinceNow: -86400 * 1),
            loggedContent: "Recent dream content",
            generatedContent: "Generated recent content",
            tags: [.school],
            image: "graduationcap.fill",
            emotion: .neutral
        )

        let dream3 = DreamModel(
            userID: "u1",
            id: "3",
            title: "Newest Dream",
            date: Date(),
            loggedContent: "Newest dream content",
            generatedContent: "Generated newest content",
            tags: [.animals],
            image: "pawprint.fill",
            emotion: .anxiety
        )

        let allDreams = [dream1, dream2, dream3]

        // Call your DreamModel function
        let recentDreams = DreamModel.getRecentDreams(from: allDreams, count: 2)
        recentDreamsOutput = recentDreams

        // Log results
        print("TEST: getRecentDreams()")
        for dream in recentDreams {
            print("- \(dream.title) (\(dream.date))")
        }
    }
}
