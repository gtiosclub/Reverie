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
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(gradient: Gradient(colors: [
                    card.cardColor.swiftUIColor,
                    card.cardColor.lighterColor.opacity(0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing))

//            RoundedRectangle(cornerRadius: 15)
//                .stroke(card.cardColor.swiftUIColor.opacity(0.7), lineWidth: 0.5)

            VStack {
                if card.id.count > 16 {
                    Text("NEW CHARACTER")
                        .padding(4)
                        .foregroundColor(.black)
                        .bold()
                } else {
                    Text("NEW AWARD")
                        .padding(4)
                        .foregroundColor(.black)
                        .bold()
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
                .frame(width: 180, height: 180)
                .padding(4)
                .shadow(color: card.cardColor.swiftUIColor.opacity(0.8), radius: 30, x: 0, y: 0)
                
                Text(card.name)
                    .font(.title)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .fontDesign(Font.Design.rounded)
                    .padding(.bottom, 6)
                
                Text(card.description)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .bold()
                
                Spacer()
            }
            .padding(10)
            .multilineTextAlignment(.center)
        }
        .bold()
        .frame(width: 320, height: 520)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    CharacterUnlockedView(card: CardModel(userID: "1", id: "ABCDEFGHIJKLMNOPQRS", name: "LIZZY", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .yellow))
}

