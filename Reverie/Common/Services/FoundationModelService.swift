//
//  FoundationModelService.swift
//  Reverie
//
//  Created by Nithya Ravula on 10/2/25.
//

import Foundation
import FoundationModels


func getOverallAnalysis(dream_description: String ) async throws -> String{
    let instructions = """
        You are an expert dream analyst.  
        For every dream description provided, write a structured analysis that follows this exact format with four categories.  
        Keep the tone empathetic, thoughtful, and insightful. Avoid repetition.  
        Use complete sentences and keep each section a short paragraph (3–6 sentences).  

        Categories:
        1. **General Review** – Summarize the dream in plain terms and highlight its overall mood or tone.  
        2. **Motifs & Symbols** – Identify recurring images, characters, or themes, and explain their symbolic meaning.  
        3. **Connection to Current Life** – Reflect on what the dream may reveal about the user’s current thoughts, feelings, or situations.  
        4. **Lessons & Takeaways** – Suggest how the user could grow, reflect, or learn from this dream in their daily life.  
        """

    let session = LanguageModelSession(instructions: instructions)
    let response = try await session.respond(to: dream_description)
    
    print(response.content)
    return response.content
    
}
