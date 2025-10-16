//
//  FloatingStickerIndividualView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/13/25.
//

import SwiftUI

struct FloatingStickerIndividualView: View {
    let character: CardModel
    let screenSize: CGSize

    @State private var position: CGPoint = .zero
    @State private var rotation: Angle = .zero
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        AsyncImage(url: URL(string: character.image ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            default:
                EmptyView()
            }
        }
        .frame(width: 75, height: 75)
        .scaleEffect(scale)
        .rotationEffect(rotation)
        .position(position)
        .onAppear {
            self.position = CGPoint(
                x: CGFloat.random(in: 0...screenSize.width),
                y: CGFloat.random(in: 0...screenSize.height)
            )
            startFloatingAnimation()
        }
    }
    
    private func startFloatingAnimation() {
        let newPosition = CGPoint(
            x: CGFloat.random(in: 0...screenSize.width),
            y: CGFloat.random(in: 0...screenSize.height)
        )
        
        let newRotation = Angle.degrees(Double.random(in: -90...90))
        let newScale = CGFloat.random(in: 0.8...1.2)
        let duration = Double.random(in: 10...20)
        
        withAnimation(.easeInOut(duration: duration)) {
            self.position = newPosition
            self.rotation = newRotation
            self.scale = newScale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            startFloatingAnimation()
        }
    }
}
