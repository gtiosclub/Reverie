//
//  CardModel.swift
//  Reverie
//
//  Created by Admin on 10/2/25.
//

import SwiftUI
import Foundation

// Model representing a dream card with various attributes and visual elements
struct CardModel: Identifiable {  // Conforms to Identifiable to uniquely identify each card in SwiftUI lists and views
    var id: UUID = UUID()  // Unique identifier for each card instance, used for identification and diffing
    
    var name: String  // Name of the character featured on the card
    var archetype: String  // Archetype or role of the character in the dream context
    var description: String  // Description or story related to the card's character or them
    var image: String?  // Optional URL to an image associated with the card
    var cardColor: Color  // Color used for the card's background or theme
    
    init(name: String, archetype: String, description: String, image: String? = nil, cardColor: Color) {
        self.id = UUID()
        self.name = name
        self.archetype = archetype
        self.description = description
        self.image = image
        self.cardColor = cardColor
    }
}
