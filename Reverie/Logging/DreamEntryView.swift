//
//  DreamEntryView.swift
//  Reverie
//
//  Created by Neel Sani on 10/2/25.
//

import SwiftUI

struct DreamEntryView: View {
    let dream: DreamModel
    @State private var goBack = false
    @State private var selectedTab = 0
    @State private var showBook = false
    @State private var glowPulse = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            BackgroundView()
            
            VStack(alignment: .leading, spacing: 1) {
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dream.title)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        Text(dream.date.formatted())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    if !dream.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(dream.tags, id: \.self) { tag in
                                    HStack {
                                        Image(systemName: DreamModel.tagImages(tag: tag))
                                            .foregroundStyle(DreamModel.tagColors(tag: tag))
                                        Text(tag.rawValue.capitalized)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 4)
                                    }
                                    .padding(.vertical, 3)
                                    .padding(.horizontal, 10)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.15))
                                    )
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                
                HStack(spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedTab = 0
                        }
                    } label: {
                        Text("Dream")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 15)
                            .padding(.vertical, 10)                            .background(
                                Capsule()
                                    .fill(selectedTab == 0 ?
                                          Color(red: 0.22, green: 0.18, blue: 0.55) : // dark purple
                                          Color.black.opacity(0.4))
                            )
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedTab = 1
                        }
                    } label: {
                        Label("Analysis", systemImage: "sparkles")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 15)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(selectedTab == 1 ?
                                          Color(red: 0.22, green: 0.18, blue: 0.55) :
                                          Color.black.opacity(0.4))
                            )
                    }
                }
                
                .padding(4)
                .glassEffect()
                .frame(maxHeight: 40)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.7))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                
                
                TabView(selection: $selectedTab) {
                    ScrollView {
                        Text(dream.loggedContent)
                            .foregroundColor(.white)
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                    .tag(0)
                    
                    ScrollView {
                        AnalysisCardView(analysis: dream.generatedContent)
                            .padding(.top, 70)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
                
                Spacer()
            }
            .padding(5)
            
            
            Button(action: {
                withAnimation(.easeInOut) {
                    showBook.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 65, height: 65)
                        .shadow(color: .purple.opacity(glowPulse ? 0.9 : 0.4),
                                radius: glowPulse ? 20 : 10)
                        .scaleEffect(glowPulse ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glowPulse)
                    
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                glowPulse = true
            }
            .padding(.trailing, 24)
            .padding(.bottom, -10)
            .buttonStyle(.plain)
            .opacity(showBook ? 0 : 1)
            
            
            if showBook {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showBook = false
                            }
                        }
                    
                    DreamBookView()
                        .frame(width: 350, height: 460)
                        .transition(.scale.combined(with: .opacity))
                }
                .zIndex(10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { goBack = true }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Archive")
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .navigationDestination(isPresented: $goBack) {
            DreamArchiveView()
        }
    }
}

#Preview {
    DreamEntryView(dream: DreamModel(
        userID: "1",
        id: "1",
        title: "Test Dream Entry",
        date: Date(),
        loggedContent: "This is a logged dream example. You can scroll through it here.",
        generatedContent: """
        **General Review**
        You saw a cow in your dream, which evoked strong emotions...
        **Motifs & Symbols**
        The cow represents your connection to...
        """,
        tags: [.mountains, .rivers],
        image: "Test",
        emotion: .happiness,
        finishedDream: "I woke up"
    ))
}
