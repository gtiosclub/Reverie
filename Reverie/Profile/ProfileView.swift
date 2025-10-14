import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    // Raw data
    @State private var dreams: [DreamModel] = []
    @State private var dreamCount: Int = 0

    // Derived stats
    @State private var recentCount: Int = 0 // based on getRecentDreams(..., count: 10)
    @State private var uniqueTagsCount: Int = 0
    @State private var topTags: [(DreamModel.Tags, Int)] = [] // top 3
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
                        StatView(stat: dreamCount, title: "Dreams Logged")
                        StatView(stat: recentCount, title: "Average Dream Length")
                        StatView(stat: uniqueTagsCount, title: "Current Streak")
                        StatView(stat: topEmotionCount, title: "Longest Streak")
                    }

                    // Top Tags row (derived via findMostCommonTags / counts)
                    if !topTags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Top Tags")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(topTags, id: \.0) { tag, count in
                                        StatView(stat: count, title: tag.rawValue.capitalized)
                                    }
                                }
                            }
                        }
                    }

                    // Per‑emotion counts (from findEmotionFrequency)
                    if !emotionCounts.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Emotions Breakdown")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            LazyVGrid(columns: columns, spacing: 18) {
                                ForEach(DreamModel.Emotions.allCases, id: \.self) { emo in
                                    let c = emotionCounts[emo] ?? 0
                                    StatView(stat: c, title: emo.rawValue.capitalized)
                                }
                            }
                        }
                    }

                    // Explore section — links to Heatmap & Constellation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explore")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        NavigationLink(destination: HeatmapView()) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Open Dream Heatmap")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 35/255, green: 31/255, blue: 49/255))
                            .cornerRadius(12)
                        }
                        NavigationLink(destination: ConstellationView(dreams: testDreams, similarityMatrix: testSimMatrix, threshold: 0.4).background(BackgroundView())) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Open Dream Constellation")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 35/255, green: 31/255, blue: 49/255))
                            .cornerRadius(12)
                        }
                        NavigationLink(destination: UserTagsView()) {
                            HStack {
                                Image(systemName: "tag")
                                Text("Browse Tags")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 35/255, green: 31/255, blue: 49/255))
                            .cornerRadius(12)
                        }
                        NavigationLink(destination: TestView()) {
                            HStack {
                                Image(systemName: "hammer")
                                Text("Test Page")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                        }
                    }

                }
                .padding(.horizontal, 16)
                .padding(.bottom, 96)
            }

            TabbarView()
        }
        .task { await fetchDreamsAndStats() }
    }
}

// MARK: - Data Fetch + Stats
extension ProfileView {
    @MainActor
    private func fetchDreamsAndStats() async {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No logged-in user")
            self.dreams = []
            applyStats()
            return
        }

        do {
            // Fetch the user's dream IDs from USERS/<uid>
            let userDocRef = db.collection("USERS").document(uid)
            struct UserProfile: Decodable { let dreams: [String] }
            let profile = try await userDocRef.getDocument(as: UserProfile.self)

            // Pull each DREAMS/<id> as DreamModel
            var fetched: [DreamModel] = []
            for id in profile.dreams {
                do {
                    let docRef = db.collection("DREAMS").document(id)
                    let document = try await docRef.getDocument()
                    let dream = try document.data(as: DreamModel.self)
                    fetched.append(dream)
                } catch {
                    print("Error fetching dream \(id): \(error)")
                }
            }

            self.dreams = fetched
            applyStats()
        } catch {
            print("❌ Error fetching or decoding user dreams: \(error.localizedDescription)")
            self.dreams = []
            applyStats()
        }
    }

    private func applyStats() {
        // Total count
        self.dreamCount = dreams.count

        // Recent count using helper (last 10)
        self.recentCount = getRecentDreams(dreams: dreams, count: 10).count

        // Tags: unique + top 3 with counts
        var tagCounter: [DreamModel.Tags: Int] = [:]
        dreams.forEach { dream in
            dream.tags.forEach { tag in tagCounter[tag, default: 0] += 1 }
        }
        self.uniqueTagsCount = Set(tagCounter.keys).count
        self.topTags = Array(tagCounter.sorted { $0.value > $1.value }.prefix(3))

        // Emotions
        self.emotionCounts = findEmotionFrequency(dreams: dreams)
        if let maxPair = emotionCounts.max(by: { $0.value < $1.value }) {
            self.topEmotion = maxPair.key
            self.topEmotionCount = maxPair.value
        } else {
            self.topEmotion = nil
            self.topEmotionCount = 0
        }
    }
}

// MARK: - Existing helper functions reused
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

#Preview {
    ProfileView()
}
