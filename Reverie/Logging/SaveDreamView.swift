//
//  SaveDreamView.swift
//  Reverie
//
//  Created by Anoushka Gudla on 9/23/25.
//

import SwiftUI
import Foundation

struct SaveDreamView: View {
    @State private var navigateToDreamEntry = false
    @State private var createdDream: DreamModel?
    @State private var showTagDropdown = false

    @Environment(\.presentationMode) var presentationMode
    
    var newDream: DreamModel
    
    struct InnerTagView: View {
        var title: String
        var body: some View {
            HStack(spacing: 5) {
                Text(title)
                    .foregroundStyle(Color.white)
                    .font(.caption)
                
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.3))
            )
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()

                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Edit Entry Tags")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showTagDropdown.toggle()
                                }
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                                    .padding(6)
                                    .background(Circle().fill(Color.white))
                            }
                            .padding(.leading, 10)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(newDream.tags, id: \.self) { tag in
                                        Button(action: {
                                            if let index = newDream.tags.firstIndex(of: tag) {
                                                newDream.tags.remove(at: index)
                                                showTagDropdown.toggle()
                                                showTagDropdown.toggle()
                                            }
                                        }) {
                                            InnerTagView(title: tag.rawValue.capitalized)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Material.thin)
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        )
                        .frame(height: 50)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)

                        
                        if showTagDropdown {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(DreamModel.Tags.allCases.filter { !newDream.tags.contains($0) }, id: \.self) { tag in
                                    Button(action: {
                                        newDream.tags.append(tag)
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            showTagDropdown = false
                                            showTagDropdown = true
                                        }
                                    }) {
                                        Text(tag.rawValue.capitalized)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 15)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(Rectangle())
                                    .background(Material.regular)
                                    
                                    if tag != DreamModel.Tags.allCases.last {
                                        Divider()
                                            .frame(height: 0.5)
                                            .background(Color.white.opacity(0.15))
                                            .padding(.horizontal, 10)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Material.regular)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .padding(.top, 5)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                NavigationLink(
                                destination: DreamEntryView(dream: createdDream ?? newDream),
                                isActive: $navigateToDreamEntry
                            ) {
                                EmptyView()
                            }
                            .hidden()
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
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await saveDream() }
                    }) {
                        Text("Save")
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
    }
    
    
    func saveDream() async {
        do {
            _ = try await FirebaseDreamService.shared.createDream(dream: newDream)
            // not on main thread, if app closed before image in done generating you lose image. may need to figure out better solution
            FirebaseDCService.shared.generateImage(for: newDream)
            FirebaseDCService.shared.generateImageForDC(for: newDream)
            createdDream = newDream
            navigateToDreamEntry = true
          
            updateTagDescriptions(tags: newDream.tags)
        } catch {
            print("Failed to save dream: \(error)")
        }
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
            image: [""],
            emotion: .happiness,
            finishedDream: "None"
        )
    )
}

