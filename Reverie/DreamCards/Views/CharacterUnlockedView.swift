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
        ZStack {
            LinearGradient(gradient: Gradient(colors: [card.cardColor.swiftUIColor, .white]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            
            RoundedRectangle(cornerRadius: 15)
                .stroke(card.cardColor.swiftUIColor, lineWidth: 6)

            VStack {
                if card.id.count > 16 {
                    Text("NEW CHARACTER")
                        .padding(4)
                        .foregroundColor(.black)
                } else {
                    Text("NEW AWARD")
                        .padding(4)
                        .foregroundColor(.black)
                }
                
                AsyncImage(url: URL(string: card.image ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.black.opacity(0.5))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "photo.fill")
                            .foregroundColor(.black.opacity(0.5))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(4)
                .shadow(color: card.cardColor.swiftUIColor.opacity(0.8), radius: 30, x: 0, y: 0)
                
                Text(card.name)
                    .font(.title)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .fontDesign(Font.Design.rounded)
                
                Text(card.description)
                    .font(.caption)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(10)
            .multilineTextAlignment(.center)
        }
        .padding()
        .opacity(1)
        .bold()
        .frame(width: 320, height: 520)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: card.cardColor.swiftUIColor.opacity(0.7), radius: 20, x: 0, y: 0)
    }
}

#Preview {
    CharacterUnlockedView(card: CardModel(userID: "1", id: "ABCDEFGHIJKLMNOPQRS", name: "LIZZY", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .yellow))
}

