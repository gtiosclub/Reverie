//
//  BookLoadingView.swift
//  Reverie
//
//  Created by Amber Verma on 11/12/25.
//

import SwiftUI
import UIKit


struct FlippingRectangle: View {
    @State private var rotation = 0.0
    @State private var xOffset: CGFloat = 35

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.white)
            .frame(width: 75, height: 132)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (0, 1, 0),
                anchor: .leading,
                perspective: 0.7
            )
            .offset(x: 37.5)
            .onAppear {
                flipLoop()
            }
    }

    private func flipLoop() {
        withAnimation(.easeInOut(duration: 0.6)) {
            rotation = -175
            xOffset = -35
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

            rotation = 0
            xOffset = 35

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                flipLoop()
            }
        }
    }
}


struct BookLoadingView: View {
    var body: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 147/255, green: 47/255, blue: 246/255), Color(red: 147/255, green: 47/255, blue: 246/255).opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 140, height: 140)
                .rotation3DEffect(.degrees(10), axis: (0, 1, 0))
                .offset(x: -10, y: 6)

            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 147/255, green: 47/255, blue: 246/255), Color(red: 147/255, green: 47/255, blue: 246/255).opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 140, height: 140)
                .rotation3DEffect(.degrees(-10), axis: (0, 1, 0))
                .offset(x: 10, y: 6)


            RoundedRectangle(cornerRadius: 6)
                .fill(Color(white: 1.0))
                .frame(width: 85, height: 135)
                .rotation3DEffect(.degrees(8), axis: (0, 1, 0))
                .offset(x: -35)

            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.white))


            }
            .frame(width: 85, height: 135)
            .rotation3DEffect(.degrees(-8), axis: (0, 1, 0))
            .offset(x: 35)


            Rectangle()
                .fill(Color.gray.opacity(0.45))
                .frame(width: 2, height: 130)
            
            FlippingRectangle()
        }
        .scaleEffect(0.6)
        .frame(width: 260, height: 180)
    }
}

#Preview {
    BookLoadingView()
        .background(Color.black)
}
