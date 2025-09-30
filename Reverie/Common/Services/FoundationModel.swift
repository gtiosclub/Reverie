//
//  FoundationModel.swift
//  Reverie
//
//  Created by Artem Kim on 9/30/25.
//

import Foundation
import FoundationModels

public class FoundationModel {
    private static let tagsInstructions: String = "There are six releated dream tags: Love, Falling, Being Chased, Family, Friends, Nightmare. You are given a dream text, identify related tags (you can choose multiple). Return an array of strings that includes the related tags listed before."
    static let tagsModelSession = LanguageModelSession(instructions: tagsInstructions)
}
