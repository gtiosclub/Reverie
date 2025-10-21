import SwiftUI
import FirebaseFirestore
import FirebaseAuth // <-- add this

struct ProfileView : View {
    @State private var dreamCount = 0

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 20) {
                Text("Reverie Profile")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("You have logged \(dreamCount) dreams")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Button to manually refresh dream count
                Button(action: {
                    fetchDreamCount()
                }) {
                    Text("Refresh Dream Count")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                NavigationLink(destination: UserTagsView()) {
                    Text("Tags View")

                }
                Text("reverie profile")
                NavigationLink(destination: TestView()) {
                    Text("Test Page")

                }
            }
            .padding()
            
            TabbarView()
        }
        .onAppear {
            fetchDreamCount()
        }
    }
    
    private func fetchDreamCount() {
        print("🔍 Fetching dream count...")
        let db = Firestore.firestore()
        
        // Get current logged-in user ID
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No logged-in user")
            return
        }
        
        let userDocRef = db.collection("USERS").document(userID)
        
        userDocRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("❌ No data found for user")
                return
            }
            
            if let dreams = data["dreams"] as? [String] {
                DispatchQueue.main.async {
                    self.dreamCount = dreams.count
                    print("✨ Updated dreamCount to: \(self.dreamCount)")
                }
            } else {
                print("❌ 'dreams' field is missing or not an array")
            }
        }
    }
}

func findMostCommonTags(dreams: [DreamModel]) -> [DreamModel.Tags] {
    var tagsDict = [DreamModel.Tags: Int]()
    
    for d in dreams {
        for t in d.tags {
            tagsDict[t, default: 0] += 1
        }
    }
    return tagsDict.sorted { $0.value > $1.value }.map { $0.key }
}

func getDreamsOfCategory(dreams: [DreamModel], category: DreamModel.Tags) -> [DreamModel] {
    return dreams.filter { dream in
        return dream.tags.contains { tag in
            return tag == category
        }
    }
}

func findEmotionFrequency(dreams: [DreamModel]) -> [DreamModel.Emotions: Int] {
    var emotionsDict = [DreamModel.Emotions: Int]()
    
    for d in dreams {
        emotionsDict[d.emotion, default: 0] += 1
    }
    return emotionsDict
}


func getRecentDreams(dreams: [DreamModel], count: Int = 10) -> [DreamModel] {
    // Make sure we don't try to return more dreams than exist
    let numberToReturn = min(count, dreams.count)
    
    // Sort dreams by date (most recent first) and return the last `numberToReturn` dreams
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


func calculateStreaks(dates: [Date]) -> (longest: Int, current: Int) {
    guard !dates.isEmpty else { return (0, 0) }

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    // Normalize and dedupe to unique calendar days
    let uniqueDates = Array(Set(dates.map { calendar.startOfDay(for: $0) })).sorted()

    var longestStreak = 1
    var streakCount = 1
    var currentStreakCount = 0

    // Seed current streak if last dream is today or yesterday
    if let lastDate = uniqueDates.last {
        let daysSinceLastDream = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
        if daysSinceLastDream <= 1 {
            currentStreakCount = 1
        }
    }

    for i in 1..<uniqueDates.count {
        let daysBetween = calendar.dateComponents([.day],
                                                  from: uniqueDates[i - 1],
                                                  to: uniqueDates[i]).day ?? 0

        if daysBetween == 1 {
            streakCount += 1
            longestStreak = max(longestStreak, streakCount)

            // If we're at the last date, update current streak if it connects to today/yesterday
            if i == uniqueDates.count - 1 {
                let lastDate = uniqueDates[i]
                let daysSinceLast = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
                if daysSinceLast <= 1 {
                    currentStreakCount = streakCount
                }
            }
        } else {
            streakCount = 1
        }
    }

    return (longestStreak, currentStreakCount)
}

func renderEmotionCircles(from dreams: [DreamModel]) -> some View {
    var emotionsDict = [DreamModel.Emotions: Int]()
    for dream in dreams {
        emotionsDict[dream.emotion, default: 0] += 1
    }

    let colorFor: (DreamModel.Emotions) -> Color = { e in
        switch e {
        case .sadness:       return .blue
        case .happiness:     return .yellow
        case .fear:          return .purple
        case .anger:         return .red
        case .embarrassment: return .orange
        case .anxiety:       return .green
        case .neutral:       return .gray
        }
    }

    // Predefined positions that are spaced apart
    let positions: [CGPoint] = [
        CGPoint(x: 160, y: 220),
        CGPoint(x: 280, y: 280),
        CGPoint(x: 100, y: 350),
        CGPoint(x: 250, y: 420),
        CGPoint(x: 200, y: 500),
        CGPoint(x: 320, y: 380),
        CGPoint(x: 140, y: 460)
    ]

    return ZStack {
        ForEach(Array(emotionsDict.keys.enumerated()), id: \.offset) { index, emotion in
            if let count = emotionsDict[emotion] {
                let size = CGFloat(80 + (count * 25)) // ✅ size = frequency-based
                let pos = index < positions.count
                    ? positions[index]
                    : CGPoint(x: 150 + CGFloat(index * 40), y: 300)

                EmotionBubbleView(
                    size: size,
                    color: colorFor(emotion),
                    start: pos,
                    jitter: max(28, min(54, size * 0.18))
                )
                .zIndex(Double(-size))
            }
        }
    }
}



#Preview {
    ProfileView()
}
