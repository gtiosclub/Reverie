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

func renderEmotionCircles(rankedEmotions: [DreamModel.Emotions: Int]) -> some View {
    VStack(spacing: 10) {
        ForEach(Array(rankedEmotions.sorted(by: { $0.value > $1.value })), id: \.key) { emotion, count in
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2))
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                Text(emotion.rawValue.capitalized)
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
    }
}



#Preview {
    ProfileView()
}
