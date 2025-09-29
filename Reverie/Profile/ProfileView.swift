import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @State private var dreamCount = 0
    var userId: String   // Pass the logged-in user's ID here

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 20) {
                Text("reverie profile")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("You have logged \(dreamCount) dreams")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Button to manually fetch dreams
                Button(action: {
                    fetchDreamCount()
                }) {
                    Text("Refresh Dream Count")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .onAppear(){
                    fetchDreamCount()
                }
            }
            
            TabbarView()
        }
    }
    
    private func fetchDreamCount() {
        Firebase.db.collection("users")
            .document(userId)
            .collection("dreams")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching dreams: \(error)")
                    return
                }
                
                if let snapshot = snapshot {
                    dreamCount = snapshot.documents.count
                    print("Fetched \(dreamCount) dreams")
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
    return tagsDict.sorted {$0.value > $1.value}.map{$0.key}
}

#Preview {
    ProfileView(userId: "OtAj4vL9Xzz8lsm4nCuL")
}
