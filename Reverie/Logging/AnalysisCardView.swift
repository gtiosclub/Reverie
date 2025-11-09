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
    let analysis: String
    var cards: [Card] { parseDreamText(text: analysis) }

    var tags: [DreamModel.Tags] = [.fire, .disasters, .water, .nature]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {

                if let overview = cards.first(where: { $0.title.lowercased().contains("overview") || $0.title.lowercased().contains("general") }) {
                    AnalysisSectionCard(title: "Overview", content: overview.content)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Themes")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(tags, id: \.self) { tag in
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(DreamModel.tagColors(tag: tag).opacity(0.25))
                                            .frame(width: 65, height: 65)
                                        Image(DreamModel.tagImages(tag: tag))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                    }
                                    Text(tag.rawValue.capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if let themeCard = cards.first(where: { $0.title.lowercased().contains("theme") || $0.title.lowercased().contains("motif") }) {
                        AnalysisSectionCard(title: "Symbols", content: themeCard.content)
                    }
                }

                if let connection = cards.first(where: { $0.title.lowercased().contains("connection") }) {
                    AnalysisSectionCard(title: "Connection to Life", content: connection.content)
                }

                if let takeaway = cards.first(where: { $0.title.lowercased().contains("takeaway") || $0.title.lowercased().contains("lesson") }) {
                    AnalysisSectionCard(title: "Takeaways", content: takeaway.content)
                }
            }
            .padding(.vertical, 25)
        }
    }
}

struct AnalysisSectionCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                    .font(.subheadline)
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
            }

            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.95))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.7),
                            Color.white.opacity(0.01)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
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
                .shadow(color: Color.white.opacity(0.1), radius: 12, x: 0, y: 0)

                .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 6)

        )
        .padding(.horizontal)
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
        let title = String(text[titleRange]).trimmingCharacters(in: .whitespacesAndNewlines)

        let start = match.range.location + match.range.length
        let end = (i + 1 < matches.count) ? matches[i + 1].range.location : nsText.length
        let contentRange = NSRange(location: start, length: end - start)
        let content = nsText.substring(with: contentRange)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        cards.append(Card(title: title, content: content))
    }

    return cards
}

#Preview {
    AnalysisCardView(
        analysis: """
        **Overview**
        Last night I dreamt about blah blah blah. Last night I dreamt about blah blah blah.

        **Themes**
        Description of analysis for themes & motifs. Last night I dreamt about blah blah blah.

        **Connection to Life**
        Last night I dreamt about blah blah blah. Last night I dreamt about blah blah blah.

        **Takeaways**
        Last night I dreamt about blah blah blah. Last night I dreamt about blah blah blah.
        """
    )
}

