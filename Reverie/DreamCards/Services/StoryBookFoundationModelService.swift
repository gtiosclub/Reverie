//
//  StoryBookFoundationModelService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/3/25.
//

import Foundation
import FoundationModels

import Foundation
import FoundationModels

class StoryBookFoundationModelService {
    static let shared = StoryBookFoundationModelService()
    
    func getPrompts(dreamText: String) async throws -> [String] {
        let instructions: String = """
        You are a creative AI assistant for a dream journaling app.
        Your task is to analyze the following dream text and return ONLY a JSON array containing exactly three strings, in this specific order: ["string 1", "scene 2", "scene 3"].

        Do not use keys or return an object. The output must be a simple, flat array of three strings.

        **Rules for the Prompts:**
        1.  **Sequence:** You must create 3 prompts that describe a natural sequence from the dream text (a beginning, a middle, and an end).
        2.  **Content:** The prompts must describe a scene, setting, or key moment. They must be simple, clear, and easy for an AI to visualize. Avoid vagueness.
        3.  **Do NOT add any style information.** Just describe the scene.
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
            throw NSError(domain: "StoryBookFoundationModelService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert response string to data."])
        }
        
        do {
            let decoder = JSONDecoder()
            let contentPrompts = try decoder.decode([String].self, from: responseData)
            
            let styleSuffix = ", in a fun and cartoonish style reminiscent of children's storybook illustration style, vibrant colors, digital art"
            
            let finalPrompts = contentPrompts.map { content in
                return content + styleSuffix
            }
            
            print("Final Prompts: \(finalPrompts)")
            return finalPrompts
            
        } catch {
            print("JSON Decoding Error: \(error)")
            throw error
        }
    }
}
