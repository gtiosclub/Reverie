import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    // Raw data
    @State private var dreams: [DreamModel] = []

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
                                .background(Color(red: 35/255, green: 31/255, blue: 49/255))
                                .cornerRadius(12)
                        }
                        NavigationLink(destination: ConstellationView(dreams: testDreams, similarityMatrix: testSimMatrix, threshold: 0.4).background(BackgroundView())) {
                            HStack { Image(systemName: "sparkles"); Text("Open Dream Constellation") }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 35/255, green: 31/255, blue: 49/255))
                                .cornerRadius(12)
                        }
                        NavigationLink(destination: UserTagsView()) {
                            HStack { Image(systemName: "tag"); Text("Browse Tags") }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 35/255, green: 31/255, blue: 49/255))
                                .cornerRadius(12)
                        }
                        NavigationLink(destination: TestView()) {
                            HStack { Image(systemName: "hammer"); Text("Test Page") }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                        }
                    }
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
        .task { await loadDreamsAndStats() }
    }
}

// MARK: - Data load + stats (robust to schema & uses in‑memory cache like TagsView)
extension ProfileView {
    /// Prefer the LoginService cache (same data path UserTagsView uses) and fall back to Firestore.
    @MainActor
    private func loadDreamsAndStats() async {
        if let cached = FirebaseLoginService.shared.currUser?.dreams, !cached.isEmpty {
            self.dreams = cached
            applyStats()
            return
        }
        await fetchDreamsFromFirestore()
    }

    /// Fallback loader: supports both user doc shapes
    /// 1) USERS/<uid>.dreams = [String] (document IDs)
    /// 2) USERS/<uid>.dreams = [[String:Any]] (embedded dream objects)
    @MainActor
    private func fetchDreamsFromFirestore() async {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No logged-in user")
            self.dreams = []
            applyStats()
            return
        }

        do {
            let userDoc = try await db.collection("USERS").document(uid).getDocument()
            guard userDoc.exists, let userData = userDoc.data() else {
                print("❌ User doc missing")
                self.dreams = []
                applyStats()
                return
            }

            var fetched: [DreamModel] = []

            if let dreamIDs = userData["dreams"] as? [String], !dreamIDs.isEmpty {
                for id in dreamIDs {
                    do {
                        let doc = try await db.collection("DREAMS").document(id).getDocument()
                        if let dream = try mapDream(from: doc) { fetched.append(dream) }
                    } catch {
                        print("Error fetching dream \(id): \(error)")
                    }
                }
            } else if let embedded = userData["dreams"] as? [[String: Any]], !embedded.isEmpty {
                for obj in embedded {
                    if let dream = mapDream(from: obj, id: obj["id"] as? String) { fetched.append(dream) }
                }
            } else {
                print("ℹ️ No dreams array on user document.")
            }

            self.dreams = fetched
            applyStats()
        } catch {
            print("❌ Error fetching or decoding user dreams: \(error.localizedDescription)")
            self.dreams = []
            applyStats()
        }
    }

    // MARK: Mapping helpers — tolerant to key/typo variations
    private func mapDream(from doc: DocumentSnapshot) throws -> DreamModel? {
        guard let data = doc.data() else { return nil }
        return mapDream(from: data, id: doc.documentID)
    }

    private func mapDream(from data: [String: Any], id: String?) -> DreamModel? {
        let userID = (data["userID"] as? String) ?? (data["userId"] as? String) ?? ""
        let title = (data["title"] as? String) ?? ""
        let loggedContent = (data["loggedContent"] as? String) ?? ""
        let generatedContent = (data["generatedContent"] as? String)
            ?? (data["genereatedContent"] as? String) // seen misspelling in UI code
            ?? ""
        let image = (data["image"] as? String) ?? ""

        var date = Date()
        if let ts = data["date"] as? Timestamp { date = ts.dateValue() }
        else if let seconds = data["date"] as? TimeInterval { date = Date(timeIntervalSince1970: seconds) }

        var tags: [DreamModel.Tags] = []
        if let tagStrings = data["tags"] as? [String] {
            tags = tagStrings.compactMap { DreamModel.Tags(rawValue: $0) }
        }

        let emotionRaw = (data["emotion"] as? String) ?? "neutral"
        let emotion = DreamModel.Emotions(rawValue: emotionRaw) ?? .neutral

        let dreamID = id ?? (data["id"] as? String ?? UUID().uuidString)
        return DreamModel(
            userID: userID,
            id: dreamID,
            title: title,
            date: date,
            loggedContent: loggedContent,
            generatedContent: generatedContent,
            tags: tags,
            image: image,
            emotion: emotion
        )
    }

    // MARK: Stats
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
        self.dreamStreak = currentDreamStreak(dreams: dreams)
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

func generateModelDreamContextByTag(dreams: [DreamModel], category: DreamModel.Tags) -> String{
    let filteredDreams : [DreamModel] = getDreamsOfCategory(dreams: dreams, category: category)
    
    let sortedDreams = filteredDreams.sorted { $0.date > $1.date }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let dreamContexts: [String] = sortedDreams.map { dream in
        let tagList = dream.tags.map { $0.rawValue }.joined(separator: ", ")
        return """
        Dream Entry:
        Date: \(dateFormatter.string(from: dream.date))
        Title: \(dream.title)
        Emotion: \(dream.emotion.rawValue)
        Tags: \(tagList)
        Content: \(dream.loggedContent)
        """
    }
    return dreamContexts.joined(separator: "\n\n---\n\n")
}

/// Current streak of consecutive calendar days with at least one dream, ending at the most recent dream's day.
func currentDreamStreak(dreams: [DreamModel]) -> Int {
    guard !dreams.isEmpty else { return 0 }
    let cal = Calendar.current
    // Deduplicate to unique days
    let uniqueDays = Set(dreams.map { cal.startOfDay(for: $0.date) })
    guard let mostRecent = uniqueDays.max() else { return 0 }

    var streak = 1
    var cursor = mostRecent
    while let prev = cal.date(byAdding: .day, value: -1, to: cursor), uniqueDays.contains(prev) {
        streak += 1
        cursor = prev
    }
    return streak
}

#Preview { ProfileView() }
