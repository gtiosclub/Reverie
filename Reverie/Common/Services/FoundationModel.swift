//
//  FoundationModel.swift
//  Reverie
//
//  Created by Artem Kim on 9/30/25.
//

import Foundation
import FoundationModels

public class FoundationModel {
    private static let tagsInstructions: String = "You are given a dream text. The only valid dream tags are: \(DreamModel.Tags.allCases.map { $0.rawValue }.joined(separator: ", ")). Identify which of these tags are relevant to the dream. Return your answer strictly as a JSON array of strings, for example: [\"family\", \"friends\"]. Rules: - You may include only tags from the list above. - Do not invent or modify tag names. - If none of the tags apply, return []. - Return only the array — no explanations or extra text."
    static let tagsModelSession = LanguageModelSession(instructions: tagsInstructions)
}
