//
//  DreamEntryView.swift
//  Reverie
//
//  Created by Neel Sani on 10/2/25.
//

import SwiftUI

struct DreamEntryView: View {
    @StateObject private var tabState = TabState()
    
    let dream: DreamModel
    @State private var goBack = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
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
                                    Text(tag.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color.white.opacity(0.15))
                                        )
                                }
                                .padding(.vertical, 4) //
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Picker("Dream Tabs", selection: $selectedTab) {
                    Text("Logged Dream").tag(0)
                    if dream.finishedDream != "None" && !dream.finishedDream.isEmpty {
                        Text("Finished Dream").tag(1)
                    }
                    Text("Dream Analysis").tag(2)
                }
                .pickerStyle(.segmented)
                .glassEffect(.regular)
                
                
                TabView(selection: $selectedTab) {
                    ScrollView {
                        Text(dream.loggedContent)
                            .foregroundColor(.white)
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                    .tag(0)
                    ScrollView {
                        Text(dream.finishedDream)
                            .foregroundColor(.white)
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                    .tag(1)
                    
                    ScrollView {
                        Text(.init(dream.generatedContent))
                            .foregroundColor(.white)
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                    .tag(2)
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        goBack = true
                    }
                }) {
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
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DreamEntryView(dream: DreamModel(
        userID: "1",
        id: "1",
        title: "Test Dream Entry",
        date: Date(),
        loggedContent: "This is a logged dream example. You can scroll through it here.",
        generatedContent: "This is a generated analysis of the dream content.",
        tags: [.mountains, .rivers],
        image: "Test",
        emotion: .happiness,
        finishedDream: "I woke up"
    ))
}
