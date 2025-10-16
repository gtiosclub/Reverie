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
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                VStack(alignment: .leading, spacing: 1) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dream.title)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        Text(dream.date.formatted())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Picker("Dream Tabs", selection: $selectedTab) {
                        Text("Logged").tag(0)
                        Text("Generated").tag(1)
                    }
                    .pickerStyle(.segmented)
                 //   .padding(.horizontal)
                //    .padding(.vertical, 6)
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
                            Text(dream.generatedContent)
                                .foregroundColor(.white)
                                .padding()
                                .multilineTextAlignment(.leading)
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: selectedTab)
                    
                    Spacer()
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
}

#Preview {
    DreamEntryView(dream: DreamModel(
        userID: "1",
        id: "1",
        title: "Test",
        date: Date(),
        loggedContent: "This is a logged dream example. You can scroll through it here.",
        generatedContent: "This is a generated analysis of the dream content.",
        tags: [.mountains, .rivers],
        image: "Test",
        emotion: .happiness
    ))
}

