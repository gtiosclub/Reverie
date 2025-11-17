//
//  TagInfoView.swift
//  Reverie
//
//  Created by Suchit Vemula on 11/5/25.
//

import SwiftUI
import Foundation
import FoundationModels
import FirebaseFirestore

struct TagDescription: Codable, Identifiable {
    @DocumentID var id: String?

    
    var description: String
    var tag: String
    var userID: String
}

struct TagInfoView: View {
    let tagGiven: DreamModel.Tags
    
    @State private var modelResponse: String = ""
    @State private var isLoading: Bool = true
    @State private var filteredDreams: [DreamModel] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                BackgroundView().ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {

                        VStack {
                            Circle()
                                .fill(Color(red: 11/255, green: 11/255, blue: 22/255))
                                .frame(width: 150, height: 150)
                                .glassEffect(.regular.interactive())
                                .overlay(
                                    Image(systemName: DreamModel.tagImages(tag: tagGiven))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(DreamModel.tagColors(tag: tagGiven))
                                        .shadow(color: DreamModel.tagColors(tag: tagGiven), radius: 25)
                                )

                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.white)
                                .padding(.top, -11.6)

                            Rectangle()
                                .frame(width: 1.2, height: 50)
                                .foregroundColor(.white)
                                .padding(.top, -16)
                                .padding(.bottom, -30)
                        }
                        .padding(.top, 110)

                        VStack(spacing: 15) {
                            HStack {
                                Spacer()
                                Text(tagGiven.rawValue.capitalized)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: DreamModel.tagColors(tag: tagGiven), radius: 12)
                                Spacer()
                            }

                            Divider()
                                .padding(.horizontal, 20)
                                .foregroundColor(.white)

                            ScrollView {
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
                        .padding(20)
                        .darkGloss()

                        HeatmapTagsView(selectedTag: tagGiven)

                        VStack(alignment: .leading, spacing: 15) {
                            Text("Found In")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .dreamGlow()

                            Divider()
                                .background(Color.white.opacity(0.3))
                                .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                ForEach(filteredDreams, id: \.id) { dream in
                                    NavigationLink(destination: DreamEntryView(dream: dream, backToArchive: false)) {
                                        VStack(spacing: 15) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 5) {
                                                    HStack(spacing: 8) {
                                                        Text(dream.title)
                                                            .font(.headline)
                                                            .foregroundColor(.white)

                                                        HStack(spacing: 4) {
                                                            ForEach(dream.tags.prefix(3), id: \.self) { tag in
                                                                Image(systemName: DreamModel.tagImages(tag: tag))
                                                                    .font(.caption)
                                                                    .foregroundColor(DreamModel.tagColors(tag: tag))
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
                                            .padding(.horizontal, 20)

                                            Divider()
                                                .background(Color.white.opacity(0.2))
                                                .padding(.leading, 25)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 80)

                    }
                }

                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.9),
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90)
                .ignoresSafeArea(edges: .top)
                .blendMode(.overlay)

                HStack {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 5/255, green: 7/255, blue: 20/255),
                                            Color(red: 17/255, green: 18/255, blue: 32/255)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 55, height: 55)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            AngularGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.8),
                                                    Color.white.opacity(0.1),
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.1),
                                                    Color.white.opacity(0.8)
                                                ]),
                                                center: .center
                                            ),
                                            lineWidth: 0.5
                                        )
                                        .blendMode(.screen)
                                )

                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding(.leading, -4)
                                .bold(true)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 8)

                    Spacer()

                    Text("Details")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.7), radius: 4)
                        .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.3), radius: 8)
                        .dreamGlow()

                    Spacer()

                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 55, height: 55)
                        .opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .background(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "#010023"), location: 0.0),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .navigationBarHidden(true)
        }
        .task {
            let dreams = FirebaseLoginService.shared.currUser?.dreams ?? []
            let context = generateModelDreamContextByTag(dreams: dreams, category: tagGiven)
            self.filteredDreams = getDreamsOfCategory(dreams: dreams, category: tagGiven)
                .sorted { $0.date > $1.date }

            if modelResponse.isEmpty {
                do {
                    let response = try await fetchOrGenerateTagDescription(context: context, tagGiven: tagGiven)
                    self.modelResponse = response
                } catch {
                    modelResponse = "Error: Could not analyze your dream. Please check your connection."
                    print("Error loading model response: \(error)")
                }

                isLoading = false
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
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

func getModelTagResponse(context: String, tagGiven: DreamModel.Tags) async throws -> String {
    
    let systemPrompt = """
    You are an expert dream analyst, acting as a pattern-finder.
    The user has provided several dream entries that they have tagged with: "\(tagGiven.rawValue)".

    Your task is to find the common thread or pattern that connects ALL of these dreams, using the tag as your central theme.

    **Theme (Tag):**
    \(tagGiven.rawValue)

    **Your Pattern Analysis:**

     Reply with a single, powerful insight based on this pattern. What might the user's subconscious be emphasizing by revisiting this theme across multiple dreams? Reference specific dream names and content in your analysis. 
    
    Reply with only the Unifying Insight. DO NOT include any headers or ** symbols. Always refer directly to the user in second person, using words such as 'you', 'yours. ALWAYS write 2 to 3 sentences. No more. No less.
    """
    
    let session = LanguageModelSession(instructions: systemPrompt)
    
    let response = try await session.respond(to: context)
    return response.content
}

func saveTagDescription(_ tagDescription: TagDescription) async throws {
    let db = Firestore.firestore()
    let collectionRef = db.collection("TAGDESCRIPTIONS")
    
    // This will create a new document in the collection
    try collectionRef.addDocument(from: tagDescription)
    print("Successfully saved new tag description to Firebase.")
}

func fetchOrGenerateTagDescription(context: String, tagGiven: DreamModel.Tags) async throws -> String {
    let db = Firestore.firestore()

    guard let userID = FirebaseLoginService.shared.currUser?.userID else {
        throw NSError(domain: "TagInfoView", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
    }

    let collectionRef = db.collection("TAGDESCRIPTIONS")
    let query = collectionRef
        .whereField("tag", isEqualTo: tagGiven.rawValue)
        .whereField("userID", isEqualTo: userID)

    let querySnapshot = try await query.getDocuments()

    if let document = querySnapshot.documents.first {
        print("Found existing tag description in Firebase.")
        let tagDescription = try document.data(as: TagDescription.self)
        return tagDescription.description
    } else {
        print("Not found in Firebase. Generating new description...")
     
        let newDescription = try await getModelTagResponse(context: context, tagGiven: tagGiven)
     
        let newTagDoc = TagDescription(
        description: newDescription,
        tag: tagGiven.rawValue,
        userID: userID
        )
     
        try await saveTagDescription(newTagDoc)
     
        return newDescription
    }
}

func updateTagDescriptions(tags: [DreamModel.Tags]) {
    Task.detached(priority: .utility) {
        do {
            guard let userID = await FirebaseLoginService.shared.currUser?.userID else {
                 print("Error: User not logged in")
                 return
            }

            let allDreams = await ProfileService.shared.dreams
            let db = Firestore.firestore()

            for tag in tags {
                let contextForTag = await generateModelDreamContextByTag(dreams: allDreams, category: tag)
                let newDescription = try await getModelTagResponse(context: contextForTag, tagGiven: tag)
                let newTagDoc = TagDescription(
                                    description: newDescription,
                                    tag: tag.rawValue,
                                    userID: userID
                                )
                
                let querySnapshot = try await db.collection("TAGDESCRIPTIONS")
                    .whereField("userID", isEqualTo: userID)
                    .whereField("tag", isEqualTo: tag.rawValue)
                    .getDocuments()
                
                print(querySnapshot.documents.first?.documentID)
                print(tag)

                if let existingDoc = querySnapshot.documents.first {
                    try await existingDoc.reference.updateData(["description": newDescription])
                } else {
                    try await db.collection("TAGDESCRIPTIONS").addDocument(from: newTagDoc)
                }
            }
        } catch {
            print("Error updating tag descriptions: \(error)")
        }
    }
}
