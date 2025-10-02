//
//  FoundationModel.swift
//  Reverie
//
//  Created by Artem Kim on 9/30/25.
//

import Foundation
import FoundationModels

public class FoundationModel {
    enum Tag: String, CaseIterable, Decodable {
        case love = "Love"
        case falling = "Falling"
        case beingChased = "Being Chased"
        case family = "Family"
        case friends = "Friends"
        case nightmare = "Nightmare"
    }
    
    private static let tagsInstructions: String = "There are six releated dream tags: \(Tag.allCases.map { $0.rawValue }.joined(separator: ", ")). You are given a dream text, identify related tags (you can choose multiple). Return an array of strings (like [\"Family\", \"Friends\"]) that includes the related tags listed before without any other text."
    static let tagsModelSession = LanguageModelSession(instructions: tagsInstructions)
}
