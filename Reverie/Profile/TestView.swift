//
//  TestView.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/30/25.
//

import SwiftUI

struct TestView: View {
    @State private var message = "Tap the button to test"

    // ✅ Sample dream data for testing (matches DreamModel structure)
    private let sampleDreams: [DreamModel] = [
        DreamModel(userID: "u1", id: "d1", title: "Beach", date: Date(),
                   loggedContent: "Sunny beach", generatedContent: "Gen A",
                   tags: [.animals], image: "img1", emotion: .happiness),
        DreamModel(userID: "u1", id: "d2", title: "Exam", date: Date(),
                   loggedContent: "Late to exam", generatedContent: "Gen B",
                   tags: [.school], image: "img2", emotion: .anxiety),
        DreamModel(userID: "u1", id: "d3", title: "Forest", date: Date(),
                   loggedContent: "Lost in woods", generatedContent: "Gen C",
                   tags: [.forests], image: "img3", emotion: .fear),
        DreamModel(userID: "u1", id: "d4", title: "Embarrassed", date: Date(),
                   loggedContent: "Forgot lines", generatedContent: "Gen D",
                   tags: [.school], image: "img4", emotion: .embarrassment),
        DreamModel(userID: "u1", id: "d5", title: "Argue", date: Date(),
                   loggedContent: "Fight with friend", generatedContent: "Gen E",
                   tags: [.rivers], image: "img5", emotion: .anger),
        DreamModel(userID: "u1", id: "d6", title: "Happy again", date: Date(),
                   loggedContent: "Won a prize", generatedContent: "Gen F",
                   tags: [.mountains], image: "img6", emotion: .happiness),
        DreamModel(userID: "u1", id: "d7", title: "Neutral day", date: Date(),
                   loggedContent: "Nothing special", generatedContent: "Gen G",
                   tags: [.animals], image: "img7", emotion: .neutral),
        DreamModel(userID: "u1", id: "d8", title: "Sad scene", date: Date(),
                   loggedContent: "Lost something", generatedContent: "Gen H",
                   tags: [.rivers], image: "img8", emotion: .sadness)
    ]

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 20) {
                Text(message)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()

                Button("Example Test") {
                    exampleTest()
                    message = "✅ Button tapped!"
                }

                Button("Emotions Dict Test") {
                    let dict = findEmotionFrequency(dreams: sampleDreams)
                    print("📊 Emotions frequency:", dict)
                    message = "📜 Printed emotions dict to console"
                }

                // 👇 Scrollable visual test area using your renderEmotionCircles()
                ScrollView {
                    renderEmotionCircles(from: sampleDreams)
                        .frame(height: 600)
                        .padding(.horizontal)
                }
            }

            TabbarView()
        }
    }
}

func exampleTest() {
    print("✅ This is logged in the console")
}

#Preview {
    TestView()
}
