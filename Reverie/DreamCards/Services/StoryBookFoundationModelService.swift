//
//  StoryBookFoundationModelService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/3/25.
//

import Foundation
import FoundationModels

class StoryBookFoundationModelService {
    static let shared = StoryBookFoundationModelService()
    
    func getPrompts(dreamText: String) async throws -> [String] {
        let instructions: String = """
        You are a world-class prompt engineer for an AI image generator that creates fun storybook images.
        Your task is to analyze the following dream text and return ONLY a JSON array containing exactly three strings, in this specific order: ["prompt 1", "prompt 2", "prompt 3"].

        Do not use keys or return an object. The output must be a simple, flat array of three strings.
        
        You will create 3 prompts in a natural sequence of the dream

        **Your Thought Process:**
        Read the dream and pick the most interesting settings. It must be something that can easily be made into an image with StableDiffusion. The prompts should be simple. NO COMPLEXITY OR VAGUENESS.

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
