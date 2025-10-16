//
//  SaveDreamView.swift
//  Reverie
//
//  Created by Anoushka Gudla on 9/23/25.
//

import SwiftUI
import Foundation

struct SaveDreamView: View {
    @State private var navigateToDreamEntry = false
    @State private var createdDream: DreamModel?
    @State private var showTagDropdown = false

    @Environment(\.presentationMode) var presentationMode
    
    var newDream: DreamModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit Entry Tags")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(newDream.tags, id: \.self) { tag in
                                        HStack(spacing: 5) {
                                            Text(tag.rawValue.capitalized)
                                                .foregroundStyle(Color.white)
                                                .font(.caption)
                                            
                                            Button(action: {
                                                if let index = newDream.tags.firstIndex(of: tag) {
                                                    newDream.tags.remove(at: index)
                                                    showTagDropdown.toggle()
                                                    showTagDropdown.toggle()
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color(white: 0.5))
                                        .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 6)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                VStack(spacing: 0) {
                                    HStack {
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                showTagDropdown.toggle()
                                            }
                                        }) {
                                            Image(systemName: "plus")
                                                .foregroundColor(.black)
                                                .padding(8)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 12)
                                    .background(Color(.darkGray))
                                    .cornerRadius(6)
                                    
                                    if showTagDropdown {
                                        VStack(alignment: .leading, spacing: 0) {
                                            ForEach(DreamModel.Tags.allCases.filter { !newDream.tags.contains($0) }, id: \.self) { tag in
                                                Button(action: {
                                                    newDream.tags.append(tag)
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                        showTagDropdown.toggle()
                                                        showTagDropdown.toggle()
                                                    }
                                                }) {
                                                    Text(tag.rawValue.capitalized)
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 10)
                                                        .padding(.horizontal, 12)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .background(Color(.darkGray))
                                                }
                                                .buttonStyle(.plain)
                                                
                                                if tag != DreamModel.Tags.allCases.last {
                                                    Divider()
                                                        .background(Color.gray.opacity(0.3))
                                                }
                                            }
                                        }
                                        .background(Color(.darkGray))
                                        .cornerRadius(6)
                                        .shadow(color: Color.black.opacity(0.6), radius: 6, x: 0, y: 3)
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .top)),
                                            removal: .opacity
                                        ))
                                        .padding(.top, 2)
                                    }
                                }
                            }
                        }
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
                        Task { await saveDream() }
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
        // not on main thread, if app closed before image in done generating you lose image. may need to figure out better solution
        FirebaseDCService.shared.generateImage(for: newDream)
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

