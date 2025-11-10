//
//  CardModel.swift
//  Reverie
//
//  Created by Admin on 10/2/25.
//

import SwiftUI
import Foundation

// Model representing a dream card with various attributes and visual elements
struct CardModel: Identifiable, Codable, Equatable {  // Conforms to Identifiable to uniquely identify each card in SwiftUI lists and views
    var userID: String
    var id: String  // Unique identifier for each card instance, used for identification and diffing
    var name: String  // Name of the character featured on the card
    //    var archetype: String  // Archetype or role of the character in the dream context
    var description: String  // Description or story related to the card's character or them
    var image: String?  // Optional URL to an image associated with the card
    var cardColor: DreamColor  // Color used for the card's background or theme
    var isShown: Bool = false // shown on screen?
    var isUnlocked: Bool = false // character unlocked?
    var isPinned: Bool = false // is the character pinned?
    var isAchievementUnlocked: Bool = false  // is the achievement unlocked
    
    enum DreamColor: String, Codable, CaseIterable, ShapeStyle {
        case purple
        case green
        case pink
        case blue
        case yellow
        case teal
        case crimson
        case indigo
        case silver
        case amber
        case emerald
        case amethyst
        case coral
        
        var swiftUIColor: Color {
            switch self {
            case .purple:
                return Color(red: 0.3, green: 0.2, blue: 0.5)
            case .green:
                return Color(red: 0.1, green: 0.3, blue: 0.2)
            case .pink:
                return Color(red: 0.9, green: 0.7, blue: 0.7)
            case .blue:
                return Color(red: 0.1, green: 0.1, blue: 0.3)
            case .yellow:
                return Color(red: 0.9, green: 0.8, blue: 0.5)
            case .teal:
                return Color(red: 0.2, green: 0.5, blue: 0.5)
            case .crimson:
                return Color(red: 0.7, green: 0.1, blue: 0.2)
            case .indigo:
                return Color(red: 0.3, green: 0.0, blue: 0.6)
            case .silver:
                return Color(red: 0.75, green: 0.75, blue: 0.8)
            case .amber:
                return Color(red: 1.0, green: 0.6, blue: 0.0)
            case .emerald:
                return Color(red: 0.1, green: 0.5, blue: 0.3)
            case .amethyst:
                return Color(red: 0.6, green: 0.4, blue: 0.8)
            case .coral:
                return Color(red: 1.0, green: 0.5, blue: 0.4)
            }
        }
    }
    
    init(userID: String, id: String, name: String, description: String, image: String? = nil, cardColor: DreamColor) {
        self.userID = userID
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        self.cardColor = cardColor
    }
}
