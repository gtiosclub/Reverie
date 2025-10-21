//
//  DCFoundationModelService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/9/25.
//

import Foundation
import FoundationModels

class DCFoundationModelService {
    func getCharacterPrompt(dreamText: String) async throws -> [String] {
        let instructions: String = """
        You are a world-class prompt engineer for an AI image generator that creates fun, cute stickers.
        Your task is to analyze the following dream text and return ONLY a JSON array containing exactly three strings, in this specific order: ["prompt", "name", "description"].

        Do not use keys or return an object. The output must be a simple, flat array of three strings.

        ---

        **1. The First String: The Sticker Prompt**
        Your goal is to create a prompt that generates a single, isolated, cute sticker with no complex background.

        **Your Thought Process:**
        1.  **Isolate Subject:** Read the dream and pick the single most interesting and tangible character or object. It must be something that can stand alone and can easily be made into a sticker with StableDiffusion. The prompt should only indicate ONE object/character. Specify the image should be a circle frame. Note that the StableDiffusion model does not know names, so much information general!! Give easy objects/animals to generate pictures from. NO COMPLEXITY OR VAGUENESS.
        2.  **Apply Sticker Style:** Combine the subject with strong, descriptive keywords to define the visual style. Use a combination of these: `die-cut sticker, vector illustration, cute chibi style, vibrant, glossy, thick cartoon outline, 2D cute`.
        3.  **Ensure No Background:** This is the most important rule. End your prompt with the keywords `, simple background, white background`. This explicitly tells the model to isolate the subject.

        **2. The Second String: The Name**
        Give the character or object a short, whimsical, and memorable name.

        ---

        **3. The Third String: The Description**
        Write a brief, story arc of the character, under 400 characters, but at least 150 characters. Give it a bit of personality or a mini-story.
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
            let characterDetails = try decoder.decode([String].self, from: responseData)
            return characterDetails
        } catch {
            print("JSON Decoding Error: \(error)")
            throw error
        }
    }
}
