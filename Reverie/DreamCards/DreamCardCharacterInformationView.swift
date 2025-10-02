//
//  DreamCardCharacterInformationView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/30/25.
//

import SwiftUI

struct DreamCardCharacterInformationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isUnlocked = false
    
    var card : CardModel // accepts the card model
    
    var body: some View {
        ZStack {
            BackgroundView()
            // Card
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("CHARACTER UNLOCKED")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 10)
                
                VStack(spacing: 16) {
                    if let imageURL = card.imageURL {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 90, height: 90)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                            case .failure:
                                Image(systemName: "square.stack.3d.up.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .foregroundColor(.white)
                            @unknown default:
                                Image(systemName: "square.stack.3d.up.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .foregroundColor(.white)
                            }
                        }
                    } else if let base64String = card.base64Image,
                              let imageData = Data(base64Encoded: base64String),
                              let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                    } else {
                        Image(systemName: "square.stack.3d.up.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.white)
                    }
                    
                    //Character Name
                    Text(card.characterName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    //Headline
                    Text(card.archetype)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                    // Description
                    Text(card.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxHeight: .infinity, alignment: .center) // keeps this chunk centered in our card
                
                Spacer()
                
                Text(card.footerText)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 10)
            }
            .frame(width: 300, height: 420)
            .background(RoundedRectangle(cornerRadius: 30)
                .fill(Color(card.cardColorName))
                // Glowing effect around the card
                .shadow(color: Color(card.cardColorName).opacity(0.7), radius: 20, x: 0, y: 0)
                .shadow(color: Color(card.cardColorName).opacity(0.4), radius: 40, x: 0, y: 0)
            )
            //Trying to see if the 3D animation
            .rotation3DEffect(.degrees(isUnlocked ? 0 : 720),
                              axis: (x: 0, y: 1, z: 0)
            ).scaleEffect(isUnlocked ? 1.0 : 0.1)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5)) {
                    isUnlocked = true
                }
            }
        }
    }
}
/*
VStack {
    Text("Dream Cards")
        .foregroundStyle(Color(.white))
    Button {
        dismiss()
    } label: {
        Image(systemName: "xmark.circle.fill")
            .font(.largeTitle)
            .foregroundColor(.gray)
            .padding()
    }
}*/

#Preview {
    // Preview using mock CardModel data for DreamCardCharacterInformationView
    DreamCardCharacterInformationView(
        card: CardModel(
            // characterName: Name of the dream character
            characterName: "Morpheus",
            // archetype: The archetype or role of the character
            archetype: "The Architect",
            // description: Short description of the character
            description: "Builds the landscapes of your dreams.",
            // footerText: Text shown in the footer of the card
            footerText: "Swipe to reveal the next insight",
            // imageURL: Optional URL for the character's image
            imageURL: nil,
            // base64Image: Optional base64-encoded image data for the character
            base64Image: nil,
            // cardColorName: The color to use for the card background
            cardColorName: Color.blue
        )
    )
}
