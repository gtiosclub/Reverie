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
    private let fms = FoundationModelService()
    @Environment(\.dismiss) private var dismiss

    
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
                        Button(action: {
                            dismiss()
                        }) {
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
                                                    center: .center,
                                                    startAngle: .degrees(0),
                                                    endAngle: .degrees(360)
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
                        
                        TextField("Dream Name", text: $title)
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                            .tint(.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                        
                        Button(action: {
                            Task {
                                isLoading = true
                                
                                do {
                                    UIApplication.shared.hideKeyboard()
                                    analysis = try await fms.getOverallAnalysis(dream_description: dream)
                                    emotion = try await fms.getEmotion(dreamText: dream)
                                    tags = try await fms.getRecommendedTags(dreamText: dream)
                                    
                                    finishedContent = try await fms.getFinishedDream(dream_description: dream)
                                    
                                    print(analysis, emotion, tags)
                                    canNavigate = true
                                } catch {
                                    print("Error during Foundation Model calls: \(error)")
                                }
                                
                                isLoading = false
                            }

                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 42/255, green: 35/255, blue: 133/255),
                                                Color(red: 64/255, green: 57/255, blue: 155/255)
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
                                                    center: .center,
                                                    startAngle: .degrees(0),
                                                    endAngle: .degrees(360)
                                                ),
                                                lineWidth: 0.5
                                            )
                                            .blendMode(.screen)
                                    )
                                    .glassEffect()

                                Image(systemName: "checkmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            .opacity(title.isEmpty || dream.isEmpty ? 0 : 1)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 8)
                        
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
                    
                    
                    ZStack(alignment: .topLeading) {
                        if (dream.isEmpty && audioManager.audioCapturerState == .stopped) {
                            Text("Last night I dreamed about...")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.vertical, 8)
                                .padding(.top, 30)
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
                        .padding(.top, 30)
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
                        .padding(.bottom, 70)
                        .padding(.leading, 290)
                    }
                }
                .padding()
                .environment(\.colorScheme, .dark)
                
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.85)
                            .ignoresSafeArea()

                        VStack(spacing: 28) {

                            BookLoadingView()
                                .scaleEffect(1.4)

                            Text("Analyzing your dream…")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.9))
                        }
                    }
                    .transition(.opacity)
                }

                TabbarView()
                    .ignoresSafeArea(edges: .bottom)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                ts.activeTab = .none
            }
        }
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoggingView()
        .environmentObject(TabState())
}
