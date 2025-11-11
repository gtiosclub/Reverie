import SwiftUI

struct CardUnlockView: View {
    @State private var loginService = FirebaseLoginService.shared
    
    var namespace: Namespace.ID
    
    @State private var dreams: [DreamModel] = []
    @State private var topThemes: [Tags] = []
    @State private var topMoods: [Emotions] = []
    @State private var totalWordCount: Int = 0
    @State private var averageWordCount: Int = 0
    
    @Binding var cards: [CardModel]
    @Binding var showUnlockView: Bool
    @Binding var showCardsCarousel: Bool
    @Binding var currentPage: Int
    
    @State var shown = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .transition(.opacity)
                .opacity(1)

            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .transition(.opacity)
            
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showCardsCarousel = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.75)) {
                        showUnlockView = false
                    }
                }
            }
            
            ZStack {
                if showUnlockView {
                    if !shown {
                        Image("pack5")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 480, height: 480)
                            .matchedGeometryEffect(id: "packAnimation", in: namespace)
                            .transition(.scale.combined(with: .opacity))
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.75)) {
                                    showCardsCarousel = true
                                    shown = true
                                }
                            }
                    } else {
                        VStack {
                            Text("Weekly Recap")
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                            TabView(selection: $currentPage) {
                                ForEach(cards.indices, id: \.self) { index in
                                    CharacterUnlockedView(card: cards[index])
                                        .padding(.horizontal, 20)
                                        .tag(index)
                                }
                                WeeklyStatView(dreams: $dreams, topThemes: $topThemes, topMoods: $topMoods, totalWordCount: $totalWordCount, averageWordCount: $averageWordCount)
                                    .padding(.horizontal, 20)
                                    .tag(cards.count)
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(height: 520)
                            .matchedGeometryEffect(id: "packAnimation", in: namespace)
                            
                            HStack(spacing: 8) {
                                ForEach(0..<(cards.count + 1), id: \.self) { index in
                                    Capsule()
                                        .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                                        .frame(width: index == currentPage ? 20 : 8, height: 6)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
        }
        .task {
            if loginService.currUser != nil {
                print("User already loaded, fetching stats.")
                do {
                    self.dreams = try await FirebaseStatCardService.shared.fetchPreviousEightDaysDreams()
                    print(dreams)
                } catch {
                    print("failed to get dreams")
                }
                calculateStatistics()
                await FirebaseUpdateCardService.shared.toggleIsUnlocked(cards:cards)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didLoginAndLoadUser)) { _ in
            print("Received didLogin notification, fetching stats.")
            Task {
                do {
                    self.dreams = try await FirebaseStatCardService.shared.fetchPreviousEightDaysDreams()
                    print(dreams)
                } catch {
                    print("failed to get dreams")
                }
                calculateStatistics()
            }
        }
    }
    private func calculateStatistics() {
        let allTags = dreams.flatMap { $0.tags }
        if !allTags.isEmpty {
            let tagCounts = allTags.reduce(into: [:]) { $0[$1, default: 0] += 1 }
            let sortedTagCounts = tagCounts.sorted { $0.value > $1.value }
            self.topThemes = sortedTagCounts.map { (tag, count) in
                return Tags(
                    name: tag.rawValue.capitalized,
                    icon: DreamModel.tagImages(tag: tag),
                    color: DreamModel.tagColors(tag: tag)
                )
            }
        }
        
        let totalLogs = dreams.count
        if totalLogs > 0 {
            let moodCounts = dreams.reduce(into: [:]) { $0[$1.emotion, default: 0] += 1 }
            let sortedMoodCounts = moodCounts.sorted { $0.value > $1.value }
            self.topMoods = sortedMoodCounts.map { (emotion, count) in
                let percentage = Int((Double(count) / Double(totalLogs)) * 100)
                return Emotions(
                    name: emotion.rawValue.capitalized,
                    percentage: percentage,
                    color: emotion.swiftUIColor
                )
            }
        }
    
        let totalWordCount = dreams.reduce(0) { $0 + $1.loggedContent.split { $0.isWhitespace || $0.isNewline }.count }
        self.totalWordCount = totalWordCount
        self.averageWordCount = dreams.isEmpty ? 0 : totalWordCount / dreams.count
    }
}

struct CardUnlockView_Previews: PreviewProvider {
    @Namespace static var ns

    static var previews: some View {
        CardUnlockPreviewWrapper()
    }

    struct CardUnlockPreviewWrapper: View {
        @State var cards = [
            CardModel(userID: "1", id: "ABCDEFGHIJKLMNOPQRS", name: "LIZZY", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .yellow),
            CardModel(userID: "1", id: "ABCDEFGHIJKLMNOPQRST", name: "KATIE", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .yellow),
            CardModel(userID: "1", id: "ABCDEFGHIJKLMNOPQRSTU", name: "KATIE", description: "Builds the landscape of your dreams", image: "lizard.fill", cardColor: .yellow)
        ]
        @State var showUnlockView = true
        @State var showCardsCarousel = false
        @State var currentPage = 0
        @Namespace var ns

        var body: some View {
            CardUnlockView(
                namespace: ns,
                cards: $cards,
                showUnlockView: $showUnlockView,
                showCardsCarousel: $showCardsCarousel,
                currentPage: $currentPage
            )
        }
    }
}
