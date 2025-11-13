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
    
    @State var newDream: DreamModel
    
    struct InnerTagView: View {
        var tag: DreamModel.Tags
        var imageName: String
        var color: Color
        var added: Bool
        
        var body: some View {
            HStack(spacing: 5) {
                Image(systemName: imageName)
                    .foregroundColor(color)
                Text(tag.rawValue.capitalized)
                    .foregroundStyle(Color.white)
                    .font(.caption)
                Image(systemName: added ? "xmark" : "plus")
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .frame(height: 20)
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
                        Text("Add Themes")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showTagDropdown.toggle()
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black)
                                    .padding(6)
                                    .background(Circle().fill(Color.white))
                                    .padding(6)
                            }
                            .padding(.leading, 10)
                            
                            Text("Search or add tags")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.caption)
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Material.thin)
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        )
                        .frame(height: 50)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        
                        if !newDream.tags.isEmpty {
                            WrappingTagsView(tags: newDream.tags) { tag in
                                Button(action: {
                                    if let index = newDream.tags.firstIndex(of: tag) {
                                        newDream.tags.remove(at: index)
                                        showTagDropdown.toggle()
                                        showTagDropdown.toggle()
                                    }
                                }) {
                                    InnerTagView(
                                        tag: tag,
                                        imageName: DreamModel.tagImages(tag: tag),
                                        color: DreamModel.tagColors(tag: tag),
                                        added: true
                                        
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 10)
                            .transition(.opacity)
                        }

                        if showTagDropdown {
                            ScrollView(.vertical, showsIndicators: true) {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(DreamModel.Tags.allCases.filter { !newDream.tags.contains($0) }, id: \.self) { tag in
                                        Button(action: {
                                            newDream.tags.append(tag)
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                showTagDropdown = false
                                                showTagDropdown = true
                                            }
                                        }) {
                                            InnerTagView(
                                                tag: tag,
                                                imageName: DreamModel.tagImages(tag: tag),
                                                color: DreamModel.tagColors(tag: tag),
                                                added: false
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .contentShape(Rectangle())
                                        
                                        .padding(.leading, 10)
                                        .padding(.trailing, 250)
                                        
                                    }
                                }
                                .contentShape(Rectangle())

                                .padding(.vertical, 5)
                            }
                            .frame(maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
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
                    destination: DreamEntryView(dream: createdDream ?? newDream, backToArchive: true),
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
            createdDream = try await FirebaseDreamService.shared.createDream(dream: newDream)
            // not on main thread, if app closed before image in done generating you lose image. may need to figure out better solution
            FirebaseDCService.shared.generateImage(for: createdDream!)
            FirebaseDCService.shared.generateImageForDC(for: createdDream!)
//            createdDream = newDream
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

struct WrappingTagsView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let tags: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(tags: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.tags = tags
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(minHeight: 0)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags), id: \.self) { tag in
                content(tag)
                    .padding(.trailing, spacing)
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > geometry.size.width) {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        if tag == tags.last {
                            width = 0
                        } else {
                            width -= d.width + spacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if tag == tags.last {
                            height = 0
                        }
                        return result
                    }
            }
        }
    }
}
