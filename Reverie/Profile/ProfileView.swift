import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var ts: TabState
    // Raw data
    @State private var dreams: [DreamModel] = ProfileService.shared.dreams

    // Top‑line stats
    @State private var dreamCount: Int = 0
    @State private var averageDreamLength: Int = 0
    @State private var dreamStreak: Int = 0  // consecutive‑day streak ending at the most recent dream date

    // Derived stats
    @State private var emotionCounts: [DreamModel.Emotions: Int] = [:]
    @State private var topEmotion: DreamModel.Emotions? = nil
    @State private var topEmotionCount: Int = 0

    // UI
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reverie Profile")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        Text("Your dream statistics and insights")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 8)

                    // Stats Grid (uses StatView)
                    LazyVGrid(columns: columns, spacing: 18) {
                        StatView(stat: dreamCount,         title: "Dreams Logged")
                        StatView(stat: averageDreamLength, title: "Average Dream Length")
                        StatView(stat: dreamStreak,        title: "Dream Streak")
                        StatView(stat: topEmotionCount,    title: "Top Emotion: \(topEmotion?.rawValue.capitalized ?? "–")")
                    }

                    // Explore section — links to Heatmap & Constellation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explore")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        NavigationLink(destination: HeatmapView()) {
                            HStack { Image(systemName: "calendar"); Text("Open Dream Heatmap") }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.profileContainer)
                                .cornerRadius(12)
                        }
                        NavigationLink(destination: ConstellationView(dreams: testDreams, similarityMatrix: testSimMatrix, threshold: 0.4).background(BackgroundView())) {
                            HStack { Image(systemName: "sparkles"); Text("Open Dream Constellation") }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.profileContainer)
                                .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: UserTagsView()) {
                            HStack { Image(systemName: "tag"); Text("Browse Tags") }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.profileContainer)
                                .cornerRadius(12)
                        }
                    }
                    renderEmotionCircles(from: .init(dreams))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 96)
            }
            .padding()
            
            VStack {
                Spacer()
                TabbarView()
            }
        }
        .task {
            await AchievementsService.shared.checkAndUnlockAchievements(dreamCount: dreamCount, dreamStreak: dreamStreak)
            applyStats()
        }
        .onAppear {
            ts.activeTab = .analytics
        }
    }
}

extension ProfileView {
    private func applyStats() {
        // Total count
        self.dreamCount = dreams.count

        // Emotions
        self.emotionCounts = findEmotionFrequency(dreams: dreams)
        if let maxPair = emotionCounts.max(by: { $0.value < $1.value }) {
            self.topEmotion = maxPair.key
            self.topEmotionCount = maxPair.value
        } else {
            self.topEmotion = nil
            self.topEmotionCount = 0
        }

        // Average length (words)
        self.averageDreamLength = averageDreamWordCount(dreams: dreams)

        // Dream streak (consecutive unique calendar days ending at most recent dream date)
        self.dreamStreak = ProfileService.shared.currentDreamStreak()
    }
}

// MARK: - Pure helpers (kept free functions so other views can reuse)
func findMostCommonTags(dreams: [DreamModel]) -> [DreamModel.Tags] {
    var tagsDict = [DreamModel.Tags: Int]()
    for d in dreams { for t in d.tags { tagsDict[t, default: 0] += 1 } }
    return tagsDict.sorted { $0.value > $1.value }.map { $0.key }
}

func getDreamsOfCategory(dreams: [DreamModel], category: DreamModel.Tags) -> [DreamModel] {
    return dreams.filter { $0.tags.contains(category) }
}

func findEmotionFrequency(dreams: [DreamModel]) -> [DreamModel.Emotions: Int] {
    var emotionsDict = [DreamModel.Emotions: Int]()
    for d in dreams { emotionsDict[d.emotion, default: 0] += 1 }
    return emotionsDict
}

func getRecentDreams(dreams: [DreamModel], count: Int = 10) -> [DreamModel] {
    let numberToReturn = min(count, dreams.count)
    let sortedDreams = dreams.sorted { $0.date > $1.date }
    return Array(sortedDreams.prefix(numberToReturn))
}

func averageDreamWordCount(dreams: [DreamModel]) -> Int {
    guard !dreams.isEmpty else { return 0 }
    let total = dreams.reduce(0) { acc, d in
        acc + d.loggedContent.split { $0.isWhitespace || $0.isNewline }.count
    }
    return total / dreams.count
}

func renderEmotionCircles(from dreams: [DreamModel]) -> some View {
    EmotionBubbleChart(dreams: dreams)
}

#Preview { ProfileView() }
