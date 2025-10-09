import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @State private var dreamCount = 0
    @State private var averageDreamLength = 0
    @State private var isLoading = false

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 20) {
                Text("Reverie Profile")
                    .font(.title)
                    .foregroundColor(.white)
                
                VStack(spacing: 10) {
                    Text("You have logged \(dreamCount) dreams")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if dreamCount > 0 {
                        Text("Average dream length: \(averageDreamLength) words")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                // Button to manually refresh dream count
                Button(action: {
                    fetchDreamStats()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isLoading ? "Loading..." : "Refresh Stats")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .disabled(isLoading)
            }
            .padding()
            
            TabbarView()
        }
        .onAppear {
            fetchDreamStats()
        }
    }
    
    private func fetchDreamStats() {
        print("🔍 Fetching dream stats...")
        isLoading = true
        let db = Firestore.firestore()
        
        // Get current logged-in user ID
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No logged-in user")
            isLoading = false
            return
        }
        
        let userDocRef = db.collection("USERS").document(userId)
        
        userDocRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user document: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            guard let data = snapshot?.data() else {
                print("❌ No data found for user")
                isLoading = false
                return
            }
            
            guard let dreamIds = data["dreams"] as? [String] else {
                print("❌ 'dreams' field is missing or not an array")
                isLoading = false
                return
            }
            
            // Update dream count
            DispatchQueue.main.async {
                self.dreamCount = dreamIds.count
                print("✨ Updated dreamCount to: \(self.dreamCount)")
            }
            
            // If no dreams, stop here
            guard !dreamIds.isEmpty else {
                isLoading = false
                return
            }
            
            // Fetch all dream documents to calculate average length
            fetchDreamLengths(dreamIds: dreamIds, db: db)
        }
    }
    
    private func fetchDreamLengths(dreamIds: [String], db: Firestore) {
        let dreamsCollection = db.collection("DREAMS")
        var totalWords = 0
        var fetchedCount = 0
        
        for dreamId in dreamIds {
            dreamsCollection.document(dreamId).getDocument { dreamSnapshot, error in
                fetchedCount += 1
                
                if let error = error {
                    print("❌ Error fetching dream \(dreamId): \(error.localizedDescription)")
                } else if let dreamData = dreamSnapshot?.data(),
                          let loggedContent = dreamData["loggedContent"] as? String {
                    let wordCount = loggedContent.split(separator: " ").count
                    totalWords += wordCount
                }
                
                // Once all dreams are fetched, calculate average
                if fetchedCount == dreamIds.count {
                    let average = dreamIds.isEmpty ? 0 : totalWords / dreamIds.count
                    DispatchQueue.main.async {
                        self.averageDreamLength = average
                        self.isLoading = false
                        print("✨ Average dream length: \(average) words")
                    }
                }
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

#Preview {
    ProfileView()
}
