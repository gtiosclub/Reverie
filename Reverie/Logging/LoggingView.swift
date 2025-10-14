//
//  LoggingView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct LoggingView: View {
    @State private var dream = ""
    @State private var title = ""
    @State private var date = Date()
    private let fms = FoundationModelService()
    
    @State private var analysis: String = ""
    @State private var emotion: DreamModel.Emotions = .neutral
    @State private var tags: [DreamModel.Tags] = []
    @State private var canNavigate = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack() {
                    HStack {
                        Spacer()
                        Button {
                            Task {
                                analysis = try await fms.getOverallAnalysis(dream_description: dream)
                                emotion = try await fms.getEmotion(dreamText: dream)
                                tags = try await fms.getRecommendedTags(dreamText: dream)
                                print(analysis, emotion, tags)
                                canNavigate = true
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .padding(6)
                                .background(Circle().fill(.gray.opacity(0.9)))
                                .padding(.vertical, 4)
                                .opacity(title.isEmpty || dream.isEmpty ? 0 : 1)
                        }
                        
                        NavigationLink(destination: SaveDreamView(newDream: DreamModel(userID: FirebaseLoginService.shared.currUser?.userID ?? "no id", id: "blank", title: title, date: date, loggedContent: dream, generatedContent: analysis, tags: tags, image: "", emotion: emotion)), isActive: $canNavigate) {
                            EmptyView()
                        }
                    }
                    HStack {
                        TextField("Dream Name", text: $title)
                            .font(.title)
                            .bold()
                        Spacer()
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                    }
                    
                    TextField("Start new dream entry...", text: $dream, axis: .vertical)
                        .padding(.vertical)
                    Spacer()
                    
                }
                .padding()
                TabbarView()
            }
        }
    }
}

#Preview {
    LoggingView()
}
