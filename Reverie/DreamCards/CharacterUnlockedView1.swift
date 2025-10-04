//
//  CharacterUnlockedView1.swift
//  Reverie
//
//  Created by Divya Mathew on 9/30/25.
//
import SwiftUI
struct CharacterUnlockedView: View {
    var name: String
    var backgroundColor: Color
    var role: String
    var description: String
    var icon: String
    var color2: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(color2, lineWidth: 6)
            .stroke(backgroundColor, lineWidth: 8)
            .fill(LinearGradient(gradient: Gradient(colors: [backgroundColor, color2]),
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing))
            .frame(width: 300, height: 475)
            .shadow(color: (color2).opacity(0.7), radius: 20, x: 0, y: 0)
            .overlay(
    
                VStack {
                    Text("CHARACTER UNLOCKED")
                        .padding()
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding(10)
                        .shadow(color: (backgroundColor).opacity(0.8), radius: 30, x: 0, y: 0)
                    Text(name)
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .fontDesign(Font.Design.rounded)
                    
                    Text(role)
                        .font(.headline)
                        .italic(true)
                      
                    Text(description)
                        .font(.caption)
                    
            
                }
                    .padding(10)
                    .multilineTextAlignment(.center)
                
            )
            .padding()
        
    }
}
struct ContentView: View {
    var body: some View {
        VStack {
            CharacterUnlockedView(name: "LIZZY", backgroundColor: Color.green, role: "The Architect", description: "Builds the landscape of your dreams", icon: "lizard.fill", color2: Color.blue)
                .opacity(0.7)
                .bold()
           
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

