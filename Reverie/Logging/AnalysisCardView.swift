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



struct CardView: View {
    let card: Card
    let isFocused: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(isFocused ? Color.purple.gradient : Color.gray.opacity(0.4).gradient)
                .shadow(radius: isFocused ? 10 : 3)

            VStack(alignment: .leading, spacing: 0) {
                Text(card.title)
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(nil, value: isFocused)
                Spacer()

                ScrollView(.vertical, showsIndicators: true) {
                    Text(card.content)
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(6)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id(card.id)
                }
                .animation(nil, value: card.id)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(width: isFocused ? 320 : 280, height: isFocused ? 440 : 400)
        .scaleEffect(isFocused ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.3), value: isFocused)
    }
}

struct AnalysisCardView: View {
    let analysis: String
    var cards: [Card] { parseDreamText(text: analysis) }
    
    @State private var currentIndex = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(cards.indices, id: \.self) { index in
                    if abs(index - currentIndex) <= 1 {
                        CardView(card: cards[index], isFocused: index == currentIndex)
                            .offset(x: positionForCard(index: index, geometry: geometry))
                            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: currentIndex)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation.width
                                    }
                                    .onEnded { gesture in
                                        let threshold = geometry.size.width / 4
                                        if gesture.translation.width < -threshold && currentIndex < cards.count - 1 {
                                            currentIndex += 1
                                        } else if gesture.translation.width > threshold && currentIndex > 0 {
                                            currentIndex -= 1
                                        }
                                        offset = 0
                                    }
                            )
                            .zIndex(index == currentIndex ? 1 : 0)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.clear))
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func positionForCard(index: Int, geometry: GeometryProxy) -> CGFloat {
        let visibleOffset: CGFloat = geometry.size.width * 0.75
        let base = CGFloat(index - currentIndex) * visibleOffset
        return base + offset
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
    AnalysisCardView(analysis: """
                     **General Review**
                     In your dream, you encountered a cow, which evoked a strong emotional response of fear. The simplicity of the scene, with just a cow present, suggests that the dream might be tapping into underlying feelings or anxieties. The overall tone of the dream seems to be one of unease or surprise, as fear is a prominent emotion you experienced.

                     **Motifs & Symbols**
                     Cows in dreams often symbolize fertility, abundance, or a connection to the earth. However, seeing a cow in a dream can also indicate feelings of vulnerability or being overwhelmed by responsibilities. The presence of fear suggests that this cow might represent something in your life that feels threatening or out of control, prompting you to confront or seek understanding about these aspects.

                     **Connection to Current Life**
                     This dream might reflect current situations where you feel burdened or uncertain about responsibilities or changes in your life. It could be a manifestation of worries about nurturing your growth or relationships, or facing challenges that require careful management. Being scared in this context suggests that there might be areas in your waking life where you feel unprepared or need more clarity.

                     **Lessons & Takeaways**
                     Reflecting on this dream, consider the areas of your life where you feel most vulnerable or overwhelmed. It might be beneficial to engage in activities that help ground you, such as mindfulness or connecting with nature, which can symbolize the nurturing aspects of a cow. Learning to approach these situations with a calm and open mind can help transform fear into understanding and empowerment.
                     """)
}

