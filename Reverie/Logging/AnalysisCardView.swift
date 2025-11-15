//
//  AnalysisCardView.swift
//  Reverie
//
//  Created by Nithya Ravula on 10/29/25.
//

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

struct AnalysisCardView: View {
    let dream: DreamModel
    var cards: [Card] { parseDreamText(text: dream.generatedContent) }

    var onTagTap: (DreamModel.Tags) -> Void = { _ in }


    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                if let overview = cards.first(where: { $0.title.lowercased().contains("overview") || $0.title.lowercased().contains("general") }) {
                    AnalysisSectionCard(title: "Overview", content: Text(overview.content))
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Themes")
                        .font(.system(size: 19).weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(dream.tags, id: \.self) { tag in
                                Button(action: {
                                    withAnimation(.easeInOut) { onTagTap(tag) }
                                }) {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.black.opacity(0.7),
                                                            Color.white.opacity(0.01)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ))
                                                .frame(width: 65, height: 65)
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(
                                                            AngularGradient(
                                                                gradient: Gradient(stops: [
                                                                    .init(color: Color.white.opacity(0.9), location: 0.15),
                                                                    .init(color: Color.white.opacity(0.1), location: 0.35),
                                                                    .init(color: Color.white.opacity(0.9), location: 0.65),
                                                                    .init(color: Color.white.opacity(0.05), location: 0.85),
                                                                    .init(color: Color.white.opacity(0.7), location: 1.00)
                                                                ]),
                                                                center: .center,
                                                                startAngle: .degrees(0),
                                                                endAngle: .degrees(360)
                                                            ),
                                                            lineWidth: 0.3
                                                        )
                                                        .blendMode(.screen)
                                                )
                                            

                                            Image(systemName: DreamModel.tagImages(tag: tag))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 32, height: 32)
                                                .foregroundStyle(DreamModel.tagColors(tag: tag))
                                        }

                                        Text(tag.rawValue.capitalized)        .font(.system(size: 10))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }

                    if let themeCard = cards.first(where: { $0.title.lowercased().contains("theme") || $0.title.lowercased().contains("motif") }) {
                        AnalysisSectionCard(title: "Symbols", content: Text(themeCard.content))
                    }
                }

                let string = Text("This dream's overall mood is ")
                    .foregroundColor(.white)
                + Text(dream.emotion.rawValue.capitalized)
                    .foregroundColor(DreamModel.emotionColors(emotion: dream.emotion).opacity(0.9))
                    .fontWeight(.semibold)
                AnalysisSectionCard(title: "Mood", content: string)

                if let connection = cards.first(where: { $0.title.lowercased().contains("connection") }) {
                    AnalysisSectionCard(title: "Connection to Life", content: Text(connection.content))
                }

                if let takeaway = cards.first(where: { $0.title.lowercased().contains("takeaway") || $0.title.lowercased().contains("lesson") }) {
                    AnalysisSectionCard(title: "Takeaways", content: Text(takeaway.content))
                }
                
                HStack() {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                        .opacity(0.7)
                    Text("This analysis was generated using your description of the dream")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .opacity(0.8)
                }
                .padding(.leading, 30)
            }
            .padding(.top, 25)
            
            
        }
        .foregroundColor(.white)
        .tint(.white)
        .environment(\.colorScheme, .dark)
    }


    
}

struct AnalysisSectionCard: View {
    let title: String
    let content: Text

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if (title != "") {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 19).weight(.bold))
                        .foregroundColor(.white)
                    
                }
            }

            content
                .font(.body)
                .foregroundColor(.white.opacity(0.95))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .darkGloss()
    }
}


func parseDreamText(text: String) -> [Card] {
    var cards: [Card] = []
    let pattern = "\\*\\*(.*?)\\*\\*"
    let regex = try! NSRegularExpression(pattern: pattern)
    let nsText = text as NSString
    let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

    for (i, match) in matches.enumerated() {
        guard let titleRange = Range(match.range(at: 1), in: text) else { continue }
        var title = String(text[titleRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        

        let start = match.range.location + match.range.length
        let end = (i + 1 < matches.count) ? matches[i + 1].range.location : nsText.length
        let contentRange = NSRange(location: start, length: end - start)
        var content = nsText.substring(with: contentRange)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if content.hasPrefix(":") {
            content = String(content.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        cards.append(Card(title: title, content: content))
    }

    return cards
}

#Preview {
    AnalysisCardView(
        dream: DreamModel(
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
            image: ["Test"],
            emotion: .happiness,
            finishedDream: "I woke up"
        )
    )
}
