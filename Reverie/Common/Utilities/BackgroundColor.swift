//
//  BackgroundColor.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/24/25.
//

import SwiftUI

struct BackgroundColor: View {
    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.14)
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(red: 0.1, green: 0.1, blue: 0.2),
//                        Color(red: 0.05, green: 0.05, blue: 0.1)
//                    ]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
                .ignoresSafeArea()

                ZStack {
                    // green
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [.green.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 1,
                                endRadius: 180
                            )
                        )
                        .frame(width: 350, height: 200)
                        .blur(radius: 70)
                        .offset(x: sin(time * 0.2) * 100, y: cos(time * 0.2) * 150)
                        .rotationEffect(.degrees(sin(time * 0.1) * 10))

                    // teal
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [.teal.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 1,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 150)
                        .blur(radius: 60)
                        .offset(x: cos(time * 0.3) * 120, y: sin(time * 0.3) * 100)
                        .rotationEffect(.degrees(cos(time * 0.2) * 15))

                    // purple
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [.purple.opacity(0.25), .clear],
                                center: .center,
                                startRadius: 1,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 250)
                        .blur(radius: 80)
                        .offset(x: sin(time * 0.1) * 100, y: cos(time * 0.15) * 120)
                }
                .blendMode(.plusLighter) //blends when colors overlap
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    BackgroundColor()
}
