//
//  DreamEntryView.swift
//  Reverie
//
//  Created by Neel Sani on 10/2/25.
//

import SwiftUI

struct DreamEntryView: View {
    let dream: DreamModel
    let backToArchive: Bool
    @State private var goBack = false
    @State private var selectedTab = 0
    @State private var showBook = false
    @State private var glowPulse = false
    @State private var selectedTag: DreamModel.Tags? = nil
    @Environment(\.dismiss) private var dismiss

    init(dream: DreamModel, backToArchive: Bool) {
        self.dream = dream
        self.backToArchive = backToArchive
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

            VStack(spacing: 0) {

                HStack {
                    Button(action: {
                        if backToArchive {
                            goBack = true
                        } else {
                            dismiss()
                        }
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

                    VStack(spacing: 2) {
                        Text(dream.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 180)
                            .multilineTextAlignment(.center)
                            .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.7), radius: 4)
                            .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.3), radius: 8)
                        Text(dream.date.formatted(.dateTime.month(.wide).day()))
                            .padding(.top, 2)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.7), radius: 4)
                            .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.3), radius: 8)
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
                                .frame(width: 55, height: 55)
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
                    .onAppear { glowPulse = true }
                    .buttonStyle(.plain)
                    .padding(.trailing, 8)
                    .opacity(showBook ? 0 : 1)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 4)

                VStack(alignment: .leading, spacing: 1) {
                    if !dream.tags.isEmpty {

                        HStack() {
                            Spacer(minLength: 0)
                            ForEach(dream.tags, id: \.self) { tag in
                                Image(systemName: DreamModel.tagImages(tag: tag))
                                    .foregroundStyle(DreamModel.tagColors(tag: tag))
                                    .padding(.vertical, 3)
                                    .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.7), radius: 4)
                                    .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.3), radius: 8)
                                
                                
                                
                            }
                            
                            Spacer(minLength: 0)
                        }
                        .padding(.bottom, 12)
                        .padding(.top, -5)
                        

                    }

                    ZStack {
                        
                        Capsule()
                            .fill(Color.black.opacity(0.35))
                            .frame(height: 43)
                            .overlay(
                                Capsule().stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.8),
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.3),
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
                            .padding(.horizontal, 15)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.easeInOut) { selectedTab = 0 }
                            }) {
                                Text("Dream")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(selectedTab == 0 ?
                                              LinearGradient(
                                                      gradient: Gradient(stops: [
                                                          .init(color: Color(red: 29/255, green: 26/255, blue: 95/255).opacity(1), location: 0.0),
                                                          .init(color: Color(red: 50/255, green: 45/255, blue: 126/255), location: 0.5),
                                                          .init(color: Color(red: 29/255, green: 26/255, blue: 95/255).opacity(1), location: 1.0)
                                                      ]),
                                                      startPoint: .leading,
                                                      endPoint: .trailing
                                                  ) :
                                                    LinearGradient(
                                                        colors: [.black, .black],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(selectedTab == 0 ? AngularGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color.white.opacity(0.5), location: 0.15),
                                                    .init(color: Color.white.opacity(0.0), location: 0.20),
                                                    .init(color: Color.white.opacity(0.6), location: 0.65),
                                                    .init(color: Color.white.opacity(0.5), location: 0.85),
                                                    .init(color: Color.white.opacity(0.7), location: 1.00)
                                                ]),
                                                center: .center,
                                                startAngle: .degrees(0),
                                                endAngle: .degrees(360)
                                            ): AngularGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0),
                                                    Color.white.opacity(0),
                                                    Color.white.opacity(0),
                                                    Color.white.opacity(0),
                                                    Color.white.opacity(0)
                                                ]),
                                                center: .center,
                                                startAngle: .degrees(0),
                                                endAngle: .degrees(360)
                                            ), lineWidth: 0.5)

                                    )
                            }
                            .buttonStyle(.plain)

                            Button(action: {
                                withAnimation(.easeInOut) { selectedTab = 1 }
                            }) {
                                HStack(spacing: 3) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.6))

                                    Text("Analysis")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.6))
                                }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(selectedTab == 1 ?
                                                  LinearGradient(
                                                          gradient: Gradient(stops: [
                                                              .init(color: Color(red: 29/255, green: 26/255, blue: 95/255).opacity(1), location: 0.0),
                                                              .init(color: Color(red: 50/255, green: 45/255, blue: 126/255), location: 0.5),
                                                              .init(color: Color(red: 29/255, green: 26/255, blue: 95/255).opacity(1), location: 1.0)
                                                          ]),
                                                          startPoint: .leading,
                                                          endPoint: .trailing
                                                      ) :
                                                        LinearGradient(
                                                            colors: [.black, .black],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        ))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(selectedTab == 1 ? AngularGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color.white.opacity(0.4), location: 0.15),
                                                    .init(color: Color.white.opacity(0.0), location: 0.20),
                                                    .init(color: Color.white.opacity(0.6), location: 0.65),
                                                    .init(color: Color.white.opacity(0.5), location: 0.85),
                                                    .init(color: Color.white.opacity(0.7), location: 1.00)
                                                ]),
                                                center: .center,
                                                startAngle: .degrees(0),
                                                endAngle: .degrees(360)
                                            ) : AngularGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0),
                                                    Color.white.opacity(0),
                                                    Color.white.opacity(0),
                                                    Color.white.opacity(0),
                                                    Color.white.opacity(0)
                                                ]),
                                                center: .center,
                                                startAngle: .degrees(0),
                                                endAngle: .degrees(360)
                                            ), lineWidth: 0.5)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        .animation(.easeInOut, value: selectedTab)

                    }

                    TabView(selection: $selectedTab) {
                        DreamShowView(dream: dream)
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
                }

                Spacer()
            }

            if showBook {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) { showBook = false }
                        }
                    
                    DreamBookView(dream: dream)
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
                    .frame(width: 320, height: 520)
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
                .zIndex(1000)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goBack) {
            DreamArchiveView()
        }
    }
}

#Preview {
    DreamEntryView(dream: DreamModel(
        userID: "1",
        id: "1",
        title: "Cave Diving",
        date: Date(),
        loggedContent: "This is a logged dream example. You can scroll through it here.",
        generatedContent: "Example",
        tags: [.mountains, .rivers],
        image: ["Test"],
        emotion: .happiness,
        finishedDream: "I woke up"
    ),
    backToArchive: false)
}
