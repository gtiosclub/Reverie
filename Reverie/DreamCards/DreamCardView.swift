//
//  DreamCardView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/23/25.
//

import SwiftUI

struct DreamCardView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Mock/sample data used for previewing and navigation testing.
    private let sampleCard = CardModel(
        id: UUID(), // Unique identifier for the card
        characterName: "Morpheus", // Name of the character featured on the card
        archetype: "The Architect", // Archetype or role of the character
        description: "Builds the landscapes of your dreams.", // Description of the character or card's them.
        imageURL: nil, // URL for an image to display on the card, if available
        base64Image: nil, // Base64-encoded image data as an alternative to imageURL
        cardColorName: Color.blue // The color theme used for the card's background or accents
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
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
                    NavigationLink(destination: DreamCardCharacterInformationView(card: sampleCard)) {
                        Text("UNLOCK CHARACTER!!")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                TabbarView()
            }
        }
    }
}

#Preview {
    DreamCardView()
}
