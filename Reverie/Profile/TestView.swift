//
//  TestView.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/30/25.
//

import SwiftUI  // ✅ Use SwiftUI, not UIKit

struct TestView: View {
    @State private var message = "Tap the button to test"

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
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
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
