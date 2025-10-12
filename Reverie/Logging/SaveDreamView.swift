//
//  SaveDreamView.swift
//  Reverie
//
//  Created by Anoushka Gudla on 9/23/25.
//

import SwiftUI
import Foundation

struct SaveDreamView: View {
    @State private var entryTitle: String = ""
    @State private var entryDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    @State private var entryTagsArray: [String] = []
    @State private var entryTags: String = ""
    @State private var showingAddTagSheet = false
    @State private var navigateToDreamEntry = false
    @State private var createdDream: DreamModel?
    var dreamAnalysis: String
    var recommendedTags: [DreamModel.Tags]
    var emotion: DreamModel.Emotions
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack (alignment: .leading, spacing: 8){
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit Entry Title")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        TextField("", text: $entryTitle)
                            .font(.title)
                            .fontWeight(.bold)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal,10)
                            .padding(.vertical,12)
                            .background(Color(.darkGray))
                            .cornerRadius(6)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit Entry Date")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.white)
                            DatePicker("", selection: $entryDate, displayedComponents: [.date])
                                .foregroundColor(.white)
                                .colorScheme(.dark)
                            Spacer()
                        }
                        .padding(.horizontal,10)
                        .padding(.vertical,12)
                        .background(Color(.darkGray))
                        .cornerRadius(6)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit Entry Tags")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack (spacing: 8){
                                ForEach(entryTagsArray, id:\.self){ tag in
                                    HStack (spacing: 5){
                                        Text(tag)
                                            .foregroundStyle(Color.white)
                                            .font(.caption)
                                        
                                        Button(action: {
                                            if let index = entryTagsArray.firstIndex(of: tag) {
                                                entryTagsArray.remove(at: index)
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Color.white)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal,10)
                                    .padding(.vertical,5)
                                    .background(Color(white:0.5))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.bottom,5)
                        
                        HStack {
                            Button(action:{
                                let trimmedTag = entryTags.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmedTag.isEmpty {
                                    entryTagsArray.append(trimmedTag)
                                    entryTags = ""
                                }
                            }){
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            TextField("",text: $entryTags)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 12)
                        .background(Color(.darkGray))
                        .cornerRadius(6)

                        
                    }
                    Spacer()
                }
                .padding()
                
            }
            .navigationBarBackButtonHidden(true)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                        Button("Back"){}
                            .foregroundColor(.white)
                        
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Save"){
                        Task {
                            await saveDream()
                        }
                    }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .background(Color(white: 0.7))
                }
            }
            .background(
                NavigationLink(destination: createdDream.map { DreamEntryView(dream: $0) }, isActive: $navigateToDreamEntry) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
    
    func saveDream() async {
        // Get user ID from FirebaseLoginService
        guard let userID = FirebaseLoginService.shared.currUser?.userID else {
            print("Error: No user ID found")
            return
        }
        
        // Convert string tags to DreamModel.Tags
        let dreamTags = entryTagsArray.compactMap { DreamModel.Tags(rawValue: $0.lowercased()) }
        
        // Create DreamModel
        let newDream = DreamModel(
            userID: userID,
            id: "temp_id", // Placeholder ID, will be replaced by createDream
            title: entryTitle.isEmpty ? "Untitled Dream" : entryTitle,
            date: entryDate,
            loggedContent: dreamAnalysis,
            generatedContent: dreamAnalysis,
            tags: dreamTags,
            image: "", // Empty placeholder for image
            emotion: emotion
        )
        
        // Call createDream
        await FirebaseDreamService.shared.createDream(dream: newDream)
        
        // Store the created dream and trigger navigation
        createdDream = newDream
        navigateToDreamEntry = true
    }
}
#Preview {
    SaveDreamView(dreamAnalysis: "analysis", recommendedTags: [], emotion: DreamModel.Emotions(rawValue: "sadness")!)
}
