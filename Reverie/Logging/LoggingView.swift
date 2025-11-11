//
//  LoggingView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct LoggingView: View {
    @EnvironmentObject var ts: TabState
    @State private var dream = ""
    @State private var title = ""
    @State private var date = Date()
    @State private var shouldFinishDream = false
    private let fms = FoundationModelService()
    
    @State private var analysis: String = ""
    @State private var emotion: DreamModel.Emotions = .neutral
    @State private var tags: [DreamModel.Tags] = []
    @State private var canNavigate = false
    @State private var finishedContent: String = "None"
    
    @State private var isLoading = false
    
    private let audioManager = AudioService()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                BackgroundView()
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Toggle("Finish Dream", isOn: $shouldFinishDream)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        Spacer()
                        Button {
                            Task {
                                isLoading = true
                                
                                do {
                                    analysis = try await fms.getOverallAnalysis(dream_description: dream)
                                    emotion = try await fms.getEmotion(dreamText: dream)
                                    tags = try await fms.getRecommendedTags(dreamText: dream)
                                    finishedContent = "None"
                                    
                                    if shouldFinishDream {
                                        finishedContent = try await fms.getFinishedDream(dream_description: dream)
                                    }
                                    
                                    print(analysis, emotion, tags)
                                    canNavigate = true
                                } catch {
                                    print("Error during Foundation Model calls: \(error)")
                                }
                                
                                isLoading = false
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Circle().fill(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.9)))
                                .padding(.vertical, 4)
                                .opacity(title.isEmpty || dream.isEmpty ? 0 : 1)
                        }
                        
                        NavigationLink(destination: SaveDreamView(newDream: DreamModel(
                            userID: FirebaseLoginService.shared.currUser?.userID ?? "no id",
                            id: "blank",
                            title: title,
                            date: date,
                            loggedContent: dream,
                            generatedContent: analysis,
                            tags: tags,
                            image: [""],
                            emotion: emotion,
                            finishedDream: finishedContent
                        )), isActive: $canNavigate) {
                            EmptyView()
                        }
                    }
                    
                    HStack {
                        ZStack(alignment: .leading) {
                            if title.isEmpty {
                                Text("Dream Name")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.custom("Inter", size: 30))
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            TextField("", text: $title)
                                .foregroundColor(.white)
                                .textFieldStyle(.plain)
                                .tint(.white)
                                .font(.title)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            DatePicker("", selection: $date, displayedComponents: [.date])
                                .glassEffect(.regular, in: .rect)
                                .labelsHidden()
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.white)
                        }
                    }
                    
                    ZStack(alignment: .topLeading) {
                        if (dream.isEmpty && audioManager.audioCapturerState == .stopped) {
                            Text("Start new dream entry...")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.vertical, 8)
                        }
                        TextField("", text: Binding(
                            get: {
                                if (audioManager.audioCapturerState == .started) {
                                    dream + audioManager.finalizedTranscript.characters + audioManager.volatileTranscript.characters
                                } else {
                                    dream
                                }
                            },
                            set: { newValue in
                                dream = newValue
                            }
                        ), axis: .vertical)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .tint(.white)
                        .padding(.vertical, 8)
                    }
                    
                    Spacer()
                    
                    switch audioManager.audioCapturerState {
                    case .started:
                        Button(action: {
                            Task {
                                do {
                                    let transcription = audioManager.finalizedTranscript.characters + audioManager.volatileTranscript.characters
                                    audioManager.resetTranscripts()
                                    if !transcription.isEmpty {
                                        if !dream.isEmpty {
                                            dream += " "
                                        }
                                        dream += transcription + " "
                                    }
                                    try await audioManager.stopTranscription()
                                    audioManager.audioCapturerState = .stopped
                                    
                                } catch (let error) {
                                    audioManager.error = error
                                }
                            }
                        }, label: {
                            Image(systemName: "square")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .background(
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 60, height: 60)
                                        .glassEffect()
                                )
                        })
                        .padding(.bottom, 60)
                        
                    case .stopped:
                        Button(action: {
                            Task {
                                do {
                                    audioManager.resetTranscripts()
                                    try await audioManager.startRealTimeTranscription()
                                    audioManager.audioCapturerState = .started
                                } catch (let error) {
                                    audioManager.error = error
                                }
                            }
                        }, label: {
                            Image(systemName: "microphone")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .background(
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 60, height: 60)
                                        .glassEffect()
                                )
                        })
                        .padding(.bottom, 60)
                    }
                }
                .padding()
                .environment(\.colorScheme, .dark)
                
                if isLoading {
                    ZStack {
                        Rectangle()
                            .fill(.black.opacity(0.6))
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("Analyzing your dream...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Material.thin)
                        )
                        .shadow(radius: 10)
                    }
                    .transition(.opacity)
                }
                
                TabbarView()
                    .ignoresSafeArea(edges: .bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                ts.activeTab = .none
            }
        }
    }
}

#Preview {
    LoggingView()
        .environmentObject(TabState())
}
