//
//  CharacterUnlockedView1.swift
//  Reverie
//
//  Created by Divya Mathew on 9/30/25.
//
import SwiftUI

struct CharacterUnlockedView: View {
    var card: CardModel
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(card.cardColor.swiftUIColor, lineWidth: 6)
            .fill(LinearGradient(gradient: Gradient(colors: [card.cardColor.swiftUIColor, .white]),
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing))
            .frame(width: 320, height: 520)
            .shadow(color: card.cardColor.swiftUIColor.opacity(0.7), radius: 20, x: 0, y: 0)
            .overlay(
                VStack {
                    Text("NEW CHARCTER")
                        .padding(4)
                    
                    // gets image url from card.image
                    AsyncImage(url: URL(string: card.image ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            Image(systemName: "photo.fill")
                                .foregroundColor(.white.opacity(0.8))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 150, height: 150)
                    .padding(4)
                    .shadow(color: card.cardColor.swiftUIColor.opacity(0.8), radius: 30, x: 0, y: 0)
                    
                    Text(card.name)
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .fontDesign(Font.Design.rounded)
                    
//                    Text(role)
//                        .font(.headline)
//                        .italic(true)
                      
                    Text(card.description)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .padding(10)
                .multilineTextAlignment(.center)
            )
            .padding()
            .opacity(1)
            .bold()
    }
}

#Preview {
    CharacterUnlockedView(card: CardModel(userID: "1", id: "1", name: "LIZZY", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .yellow))
}

