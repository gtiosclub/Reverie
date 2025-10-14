//
//  SaveDreamView.swift
//  Reverie
//
//  Created by Anoushka Gudla on 9/23/25.
//

import SwiftUI
import Foundation

struct SaveDreamView: View {
    @State private var entryTags: String = ""
    @State private var showingAddTagSheet = false
    @State private var navigateToDreamEntry = false
    @State private var createdDream: DreamModel?
    
    @Environment(\.presentationMode) var presentationMode
    
    var newDream: DreamModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    // --- Tags Section ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit Entry Tags")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(newDream.tags, id: \.self) { tag in
                                    HStack(spacing: 5) {
                                        Text(tag.rawValue)
                                            .foregroundStyle(Color.white)
                                            .font(.caption)
                                        
                                        Button(action: {
                                            if let index = newDream.tags.firstIndex(of: tag) {
                                                newDream.tags.remove(at: index)
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Color.white)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color(white: 0.5))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.bottom, 5)
                        
                        HStack {
                            Button(action: {
                                let trimmedTag = entryTags.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmedTag.isEmpty {
                                    if let tag = DreamModel.Tags(rawValue: trimmedTag) {
                                        newDream.tags.append(tag)
                                    }
                                    entryTags = ""
                                }
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            
                            TextField("", text: $entryTags)
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
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await saveDream()
                        }
                    }) {
                        Text("Save")
                            .font(.body.bold())
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: createdDream.map { DreamEntryView(dream: $0) },
                    isActive: $navigateToDreamEntry
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func saveDream() async {
        await FirebaseDreamService.shared.createDream(dream: newDream)
        createdDream = newDream
        navigateToDreamEntry = true
    }
}

#Preview {
    SaveDreamView(
        newDream: DreamModel(
            userID: "idk",
            id: "idk",
            title: "idk",
            date: Date(),
            loggedContent: "",
            generatedContent: "",
            tags: [],
            image: "",
            emotion: .happiness
        )
    )
}
