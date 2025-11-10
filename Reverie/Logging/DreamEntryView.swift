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
    @State private var selectedTag: DreamModel.Tags? = nil

    
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
                        AnalysisCardView(
                            dream: dream,
                            onTagTap: { tag in
                                withAnimation(.easeInOut) { selectedTag = tag }
                            }
                        )
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
            if let tag = selectedTag {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) { selectedTag = nil }
                        }

                    VStack(spacing: 16) {
                        Text(tag.rawValue.capitalized)
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text("Information about this tag could go here.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)
                    }
                    .frame(width: 300, height: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(DreamModel.tagColors(tag: tag).opacity(0.6), lineWidth: 1)
                            )
                            .shadow(color: DreamModel.tagColors(tag: tag).opacity(0.4), radius: 15)
                    )
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
                    }
                    .foregroundColor(.white)
                }
            }
            
        }
        .navigationDestination(isPresented: $goBack) {
            DreamArchiveView()
            
        }
        .overlay {
            if let tag = selectedTag {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) { selectedTag = nil }
                        }

                    VStack(spacing: 16) {
                        Image(systemName: DreamModel.tagImages(tag: tag))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(DreamModel.tagColors(tag: tag))
                        Text(tag.rawValue.capitalized)
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text(DreamModel.tagDescription(tag: tag))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)
                    }
                    .frame(width: 320, height: 500)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(DreamModel.tagColors(tag: tag).opacity(0.6), lineWidth: 1)
                            )
                            .shadow(color: DreamModel.tagColors(tag: tag).opacity(0.4), radius: 15)
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                .transition(.opacity)
                .zIndex(1000)
            }
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
        In your dream, you encountered a cow, which evoked a strong emotional response of fear. The simplicity of the scene, with just a cow present, suggests that the dream might be tapping into underlying feelings or anxieties. The overall tone of the dream seems to be one of unease or surprise, as fear is a prominent emotion you experienced.

        **Motifs & Symbols**  
        Cows in dreams often symbolize fertility, abundance, or a connection to the earth. However, seeing a cow in a dream can also indicate feelings of vulnerability or being overwhelmed by responsibilities. The presence of fear suggests that this cow might represent something in your life that feels threatening or out of control, prompting you to confront or seek understanding about these aspects.

        **Connection to Current Life**  
        This dream might reflect current situations where you feel burdened or uncertain about responsibilities or changes in your life. It could be a manifestation of worries about nurturing your growth or relationships, or facing challenges that require careful management. Being scared in this context suggests that there might be areas in your waking life where you feel unprepared or need more clarity.

        **Lessons & Takeaways**  
        Reflecting on this dream, consider the areas of your life where you feel most vulnerable or overwhelmed. It might be beneficial to engage in activities that help ground you, such as mindfulness or connecting with nature, which can symbolize the nurturing aspects of a cow. Learning to approach these situations with a calm and open mind can help transform fear into understanding and empowerment.
        """,
        tags: [.mountains, .rivers],
        image: "Test",
        emotion: .happiness,
        finishedDream: "I woke up"
    ))
}
