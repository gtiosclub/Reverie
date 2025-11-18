//
//  FoundationModelService.swift
//  Reverie
//
//  Created by Nithya Ravula on 10/2/25.
//

import Foundation
import FoundationModels

class FoundationModelService {
    
    @Generable
    struct EmotionSuggestion {
        @Guide(description: "The overall emotion of the dream.")
        let emotion: DreamModel.Emotions
    }
    
    @Generable
    struct TagsSuggestion {
        @Guide(description: "The tags/themes applicable to the dream.")
        let tags: [DreamModel.Tags]
    }
    
    func getOverallAnalysis(dream_description: String ) async throws -> String{
        let instructions = """
        You are an expert dream analyst.  
        For every dream description provided, write a structured analysis that follows this exact format with four categories.  
        Keep the tone empathetic, thoughtful, and insightful. Avoid repetition.  
        Use complete sentences and keep each section a short paragraph (2–4 sentences). 
        Do now use ":" after each title, just use **Title** Text.
        
        Categories:
        1. **General Review** – Summarize the dream in plain terms and highlight its overall mood or tone.  
        2. **Motifs & Symbols** – Identify recurring images, characters, or themes, and explain their symbolic meaning.  
        3. **Connection to Current Life** – Reflect on what the dream may reveal about the user’s current thoughts, feelings, or situations.  
        4. **Lessons & Takeaways** – Suggest how the user could grow, reflect, or learn from this dream in their daily life.  
        """
        
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: dream_description)
        
//        print(response.content)
        return response.content
        
    }
    
    func getPrompting(dreamFragment: String) async throws -> String {
        let instructions = """
        You are a dream therapist.
        You will be provided a fragment of a dream that the user inputs.
        Your job is to return a question to ask the user. The goal is to prompt the user for more details about their dream they may have forgotten.
        """
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: dreamFragment)
        
        print(response.content)
        return response.content
    }
    

    func getRecommendedTags(dreamText: String) async throws -> [DreamModel.Tags] {
        let tagsInstructions: String = "You are given a dream text. The only valid dream tags are (use exact spelling): \(DreamModel.Tags.allCases.map { $0.rawValue }.joined(separator: ", ")). Identify which of these tags are relevant to the dream. Return your answer strictly as a JSON array of strings, for example: [\"family\", \"friends\"]. Rules: - You may include only tags from the list above. - Do NOT return an object, dictionary, or key-value structure - Do not invent or modify tag names, use the tag names exactly as written (including pluralization and spelling) - Do not singularize, pluralize, or modify words - If none of the tags apply, return []. - Return only the JSON array, no code blocks, no text — no explanations or extra text. - If there are no tags that apply to the dream, return an empty array []"
        let tagsModelSession = LanguageModelSession(instructions: tagsInstructions)
        do {
            let response = try await tagsModelSession.respond(to: dreamText, generating: TagsSuggestion.self)
            print("TAGS: ", response.content)
            return response.content.tags
        } catch {
            print(error)
            return []
        }
   }

   func getEmotion(dreamText: String) async throws -> DreamModel.Emotions {
       let emotionsInstructions: String = "You are given a dream text. The only valid emotions are: \(DreamModel.Emotions.allCases.map { $0.rawValue }.joined(separator: ", ")). Identify the single overall emotion that best matches the dream. Return your answer strictly as a string, for example: \"happiness\". Rules: - You must return exactly one emotion from the list above. - Do not invent, modify, or explain emotions. - If no emotion clearly applies, return \"neutral\". - Return only the string — no array, no extra text, no explanation."
       let emotionsModelSession = LanguageModelSession(instructions: emotionsInstructions)
       
       do {
           let response = try await emotionsModelSession.respond(to: dreamText, generating: EmotionSuggestion.self)
           print("Emotion: ", response.content)
           return response.content.emotion
       } catch {
           print(error)
           return .neutral
       }
   }

     
    func getFinishedDream(dream_description: String ) async throws -> String{
        let instructions = """
        Instruction (Strict):
        You are a memory editor. The user's text is a dream description that may feel unfinished. 
        Your goal is to lightly correct grammar and flow, and then complete the dream in a natural and interesting way — as if the user remembered the entire dream clearly. 
        You may extend the dream slightly, but stay fully consistent with the tone, imagery, and logic already present. 
        Do not add new characters, places, or storylines that weren’t implied by the user’s text. 
        If the user mentions waking up, remove that part and instead finish the dream right before they woke up. 
        The result should feel vivid and complete, like the final moments of the dream unfolded naturally. 
        Return only the finished dream text, with no explanations or extra formatting.
        Do not include any preface, explanation, or introductory phrases. Output only the finished dream text.

        
        """
        
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: dream_description)
        
//        print(response.content)
        return response.content
        
    }

}
