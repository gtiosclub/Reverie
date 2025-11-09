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
    
    init(dream: DreamModel) {
        self.dream = dream
        let appearance = UISegmentedControl.appearance()
        appearance.backgroundColor = UIColor(Color.black.opacity(0.9))
        appearance.selectedSegmentTintColor = UIColor(Color(red: 0.27, green: 0.22, blue: 0.55))
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ]
        appearance.setTitleTextAttributes(normalAttrs, for: .normal)
        appearance.setTitleTextAttributes(selectedAttrs, for: .selected)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            BackgroundView()
            
            VStack(alignment: .leading, spacing: 1) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(){
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dream.title)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            Text(dream.date.formatted())
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showBook.toggle()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 46/255, green: 39/255, blue: 137/255),
                                                Color(red: 64/255, green: 57/255, blue: 155/255)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 45, height: 45)
                                    .shadow(
                                        color: Color(red: 60/255, green: 53/255, blue: 151/255)
                                            .opacity(glowPulse ? 0.9 : 0.4),
                                        radius: glowPulse ? 10 : 5
                                    )
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
                                            .shadow(color: .white.opacity(0.25), radius: 1)
                                    )


                                Image(systemName: "book.closed.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }


                        }
                        .onAppear {
                            glowPulse = true
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, -6)
                        .buttonStyle(.plain)
                        .opacity(showBook ? 0 : 1)

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
                
                
                ZStack {
                    Capsule()
                        .fill(Color.black)
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.25),
                                            Color.white.opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .shadow(color: .white.opacity(0.2), radius: 1)
                                .blendMode(.screen)
                        )
                        .overlay(
                            HStack {
                                Spacer()
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.35),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 1)
                                Spacer()
                            }
                        )
                        .frame(height: 30.5)
                        .padding(.horizontal)

                    Picker("Dream Tabs", selection: $selectedTab) {
                        Text("Dream").tag(0)
                        Text("Analysis").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .glassEffect(.regular)
                    .padding(.horizontal)
                }



                  
                
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
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
                
                Spacer()
            }
            .padding(5)
            
            

            
            
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
