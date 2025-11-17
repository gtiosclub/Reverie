//
//  DCFoundationModelService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/9/25.
//

import Foundation
import FoundationModels

class DCFoundationModelService {
    static let shared = DCFoundationModelService()
    
    func getCharacterPrompt(dreamText: String) async throws -> [String] {
        let instructions: String = """
        You are a creative AI for a dream journaling app.
        Your task is to analyze the following dream text and return ONLY a JSON array containing exactly three strings, in this specific order: ["subject", "name", "description"].

        Do not use keys or return an object. The output must be a simple, flat array of three strings.

        ---
        **1. The First String: The Sticker Subject**
        Read the dream and pick the single most interesting, simple, and tangible character or object.
        - The subject must be a single item, not a scene.
        - Give easy objects/animals to generate. NO COMPLEXITY OR VAGUENESS.
        - Do NOT add any style keywords like "sticker" or "vector".
        - It should not be plural

        **2. The Second String: The Name**
        Give the character or object a short, whimsical, and memorable name.

        **3. The Third String: The Description**
        Write the significance of the character, between 20 and 60 characters.
        """
        let ModelSession = LanguageModelSession(instructions: instructions)
        
        let response = try await ModelSession.respond(to: dreamText)
        let responseString = response.content
        print("Model Response String: \(responseString)")
        
        var cleanString = responseString
        if let startIndex = cleanString.firstIndex(of: "["),
           let endIndex = cleanString.lastIndex(of: "]") {
            cleanString = String(cleanString[startIndex...endIndex])
        }
        
        guard let responseData = cleanString.data(using: .utf8) else {
            throw NSError(domain: "DCFoundationModelService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert response string to data."])
        }
        
        do {
            let decoder = JSONDecoder()
            var characterDetails = try decoder.decode([String].self, from: responseData)
            
            guard characterDetails.count == 3 else {
                throw NSError(domain: "DCFoundationModelService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Model returned an invalid array count."])
            }
            
            let styleSuffix = ", cute character, flat vector illustration, thick bold outline, die-cut sticker style, smooth shading, vibrant colors, simple white background, centered composition, high contrast"
            
            let contentPrompt = characterDetails[0]
            characterDetails[0] = contentPrompt + styleSuffix
            
            print("Final Prompt: \(characterDetails[0])")
            
            return characterDetails
            
        } catch {
            print("JSON Decoding Error: \(error)")
            throw error
        }
    }
}
