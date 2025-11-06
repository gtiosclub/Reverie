//
//  TagInfoView.swift
//  Reverie
//
//  Created by Suchit Vemula on 11/5/25.
//

import SwiftUI
import Foundation
import FoundationModels

struct TagInfoView: View {
    let tagGiven: DreamModel.Tags
    
    @State private var modelResponse: String = ""
    @State private var isLoading: Bool = true
    @State private var filteredDreams: [DreamModel] = []
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Rectangle()
                            .frame(width: 24, height: 24)
                            .hidden()
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack {
                        Circle()
                            .fill(Color(red: 11/255, green: 11/255, blue: 22/255))
                            .frame(width: 150, height: 150)
                            .glassEffect(.regular.interactive())
                            .overlay(
                                Image(systemName: DreamModel.getTagImage(tag: tagGiven))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(getTagColor(tag: tagGiven))
                                
                            )
                        
                        Rectangle()
                            .frame(width: 2, height: 20)
                            .foregroundColor(.gray)
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 20) {
                        HStack {
                            
                            Spacer()
                            Text(tagGiven.rawValue.capitalized)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            
                        }
                        Divider()
                            .padding(.horizontal, 40)
                        ScrollView{
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding()
                            } else {
                                Text(modelResponse)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .frame(minHeight: 260, maxHeight: 300)
                        
                    }
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(red: 11/255, green: 11/255, blue: 22/255))
                            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Found In")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal, 25)
                    
                    VStack(spacing: 0) {
                        ForEach(filteredDreams, id: \.id) { dream in
                            NavigationLink(destination: DreamEntryView(dream: dream, backButtonLabel: "")) {
                                VStack(spacing: 15) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack(spacing: 8) {
                                                Text(dream.title)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                
                                                HStack(spacing: 4) {
                                                    ForEach(dream.tags.prefix(3), id: \.self) { tag in
                                                        Image(systemName: DreamModel.getTagImage(tag: tag))
                                                            .font(.caption)
                                                            .foregroundColor(getTagColor(tag: tag))
                                                    }
                                                }
                                            }
                                            Text(formatDate(dream.date))
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 25)
                                    
                                    Divider()
                                        .background(Color.white.opacity(0.2))
                                        .padding(.leading, 25)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
                .padding(.top, 50)
            }
            .task {
                let dreams = fetchDreams()
                let context = generateModelDreamContextByTag(dreams: dreams, category: tagGiven)
                self.filteredDreams = getDreamsOfCategory(dreams: dreams, category: tagGiven)
                                        .sorted { $0.date > $1.date }
            
                if(modelResponse == ""){
                    do {
                        let response = try await getModelTagResponse(context: context, tagGiven: tagGiven)
                        
                        modelResponse = response
                        
                    } catch {
                        modelResponse = "Error: Could not analyze your dream. Please check your connection."
                        print("Error loading model response: \(error)")
                    }
                    
                    isLoading = false
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }

    private func getTagColor(tag: DreamModel.Tags) -> Color {
        switch tag {
        case .rivers: return .blue.opacity(0.8)
        case .forests: return .green.opacity(0.8)
        case .animals: return .orange.opacity(0.8)
        case .mountains: return .gray.opacity(0.8)
        case .school: return .yellow.opacity(0.8)
        }
    }
}


func generateModelDreamContextByTag(dreams: [DreamModel], category: DreamModel.Tags) -> String{
    let filteredDreams : [DreamModel] = getDreamsOfCategory(dreams: dreams, category: category)
    
    let sortedDreams = filteredDreams.sorted { $0.date > $1.date }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let dreamContexts: [String] = sortedDreams.map { dream in
        let tagList = dream.tags.map { $0.rawValue }.joined(separator: ", ")
        return """
        Dream Entry:
        Date: \(dateFormatter.string(from: dream.date))
        Title: \(dream.title)
        Emotion: \(dream.emotion.rawValue)
        Tags: \(tagList)
        Content: \(dream.loggedContent)
        """
    }
    return dreamContexts.joined(separator: "\n\n---\n\n")
}

func fetchDreams() -> [DreamModel] {
    guard let user = FirebaseLoginService.shared.currUser else {
        print("No current user found")
        return []
    }
    
    return user.dreams
}

func getModelTagResponse(context: String, tagGiven: DreamModel.Tags) async throws -> String {
    
    let systemPrompt = """
    You are an expert dream analyst, acting as a pattern-finder.
    The user has provided several dream entries that they have tagged with: "\(tagGiven.rawValue)".

    Your task is to find the common thread or pattern that connects ALL of these dreams, using the tag as your central theme.

    **Theme (Tag):**
    \(tagGiven.rawValue)

    **Your Pattern Analysis:**

     Reply with a single, powerful insight based on this pattern. What might the user's subconscious be emphasizing by revisiting this theme across multiple dreams?
    
    Reply with only the Unifying Insight. DO NOT include any headers or ** symbols. Always refer directly to the user in second person, using words such as 'you', 'yours. ALWAYS write 2 to 3 sentences. No more. No less.
    """
    
    let session = LanguageModelSession(instructions: systemPrompt)
    
    let response = try await session.respond(to: context)
    return response.content
}
