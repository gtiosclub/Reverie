import SwiftUI
import FirebaseFirestore
import FirebaseAuth
struct ProfileView: View {
 @State private var dreamCount = 0
 @State private var averageDreamLength = 0
 @State private var longestStreak = 0
 @State private var currentStreak = 0
 @State private var totalWords = 0
 @State private var isLoading = false
 var body: some View {
 ZStack {
 BackgroundView()

 ScrollView {
 VStack(spacing: 24) {
 // Header
 VStack(spacing: 8) {
 Text("Your Dream Journey")
 .font(.system(size: 32,
weight: .bold))
 .foregroundColor(.white)

if isLoading {
 ProgressView()
 .progressViewStyle(CircularProgressViewStyle(tint: .white))
 .scaleEffect(1.2)
 .padding(.top, 8)
 }
 }
 .padding(.top, 40)

if dreamCount > 0 {
 // Main Stats Grid
 LazyVGrid(columns:
[GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
 StatCard(value: "\(dreamCount)",
label: "Dreams Logged", icon: "moon.stars.fill")
 StatCard(value: "\(currentStreak)",
label: "Current Streak", icon: "flame.fill", accentColor:
currentStreak > 0 ? .orange : .white)
 StatCard(value: "\(longestStreak)",
label: "Best Streak", icon: "trophy.fill",
accentColor: .yellow)
 StatCard(value: "\(averageDreamLength)", label: "Avg Words", icon:
"text.alignleft")
 }
 .padding(.horizontal)

 // Total Words Card
 HStack {
 Image(systemName: "book.fill")
 .font(.system(size: 24))
 .foregroundColor(.purple.opacity(0.8))

 VStack(alignment: .leading,
spacing: 4) {
 Text("Total Words Written")
 .font(.subheadline)
 .foregroundColor(.white.opacity(0.7))
 Text("\(totalWords)")
 .font(.system(size: 28,
weight: .bold))
 .foregroundColor(.white)
 }

 Spacer()
 }
 .padding()
 .background(
 RoundedRectangle(cornerRadius: 16)
 .fill(Color.white.opacity(0.1))
 )
 .padding(.horizontal)
 } else {
 // Empty State
 VStack(spacing: 16) {
 Image(systemName: "moon.zzz.fill")
 .font(.system(size: 60))
 .foregroundColor(.white.opacity(0.3))

 Text("No dreams logged yet")
 .font(.title3)
 .foregroundColor(.white.opacity(0.7))

 Text("Start your journey by logging your first dream")
 .font(.subheadline)
 .foregroundColor(.white.opacity(0.5))
 .multilineTextAlignment(.center
)
 }
 .padding(.top, 60)
 }

 // Refresh Button
 Button(action: {
 fetchDreamStats()
 }) {
 HStack {
 Image(systemName:
"arrow.clockwise")
 Text("Refresh Stats")
 }
 .font(.system(size: 16,
weight: .semibold))
 .foregroundColor(.white)
 .frame(maxWidth: .infinity)
 .padding()
 .background(
 RoundedRectangle(cornerRadius: 12)
 .fill(Color.blue.opacity(0.6))
 )
 }
 .disabled(isLoading)
 .padding(.horizontal)
 .padding(.top, 8)
 .padding(.bottom, 100)
 }
 .padding(.horizontal, 4)
 }
 
 TabbarView()
 }
 .onAppear {
 fetchDreamStats()
 }
 }

 private func fetchDreamStats() {
 print("Fetching dream stats...")
 isLoading = true
     let db = Firestore.firestore()

 guard let userId = Auth.auth().currentUser?.uid else {
 print("No logged-in user")
 isLoading = false
 return
 }

     let userDocRef = db.collection("USERS").document(userId)

 userDocRef.getDocument { snapshot, error in
 if let error = error {
 print("Error fetching user document: \(error.localizedDescription)")
 isLoading = false
 return
}

 guard let data = snapshot?.data() else {
 print("No data found for user")
 isLoading = false
 return
 }

 guard let dreamIds = data["dreams"] as? [String]
else {
 print("'dreams' field is missing or not an array")
 isLoading = false
 return
 }

 DispatchQueue.main.async {
     self.dreamCount = dreamIds.count
 print("Updated dreamCount to: \(self.dreamCount)")
 }

 guard !dreamIds.isEmpty else {
 isLoading = false
 return
 }

 fetchDreamDetails(dreamIds: dreamIds, db: db)
 }
 }

 private func fetchDreamDetails(dreamIds: [String], db:
Firestore) {
     let dreamsCollection = db.collection("DREAMS")
 var words = 0
 var fetchedCount = 0
 var dreamDates: [Date] = []

 for dreamId in dreamIds {
 dreamsCollection.document(dreamId).getDocument
{ dreamSnapshot, error in
 fetchedCount += 1

 if let error = error {
 print("Error fetching dream \(dreamId):\(error.localizedDescription)")
 } else if let dreamData = dreamSnapshot?.data()
{
 if let loggedContent =
dreamData["loggedContent"] as? String {
 let wordCount =
loggedContent.split(separator: " ").count
 words += wordCount
 }

if let timestamp = dreamData["date"] as?
Timestamp {

dreamDates.append(timestamp.dateValue())
 }
 }

 if fetchedCount == dreamIds.count {
     let average = dreamIds.isEmpty ? 0 :
words / dreamIds.count
 let streaks = calculateStreaks(dates:
dreamDates)

 DispatchQueue.main.async {
     self.averageDreamLength = average
     self.totalWords = words
     self.longestStreak = streaks.longest
     self.currentStreak = streaks.current
     self.isLoading = false
 print("Stats updated - Avg: \(average), Total: \(words), Current: \(streaks.current), Best:\(streaks.longest)")
 }
 }
 }
 }
 }

 private func calculateStreaks(dates: [Date]) -> (longest:
Int, current: Int) {
 guard !dates.isEmpty else { return (0, 0) }

 let calendar = Calendar.current
 let today = calendar.startOfDay(for: Date())

     let sortedDates = dates.sorted()
     let normalizedDates = sortedDates.map
{ calendar.startOfDay(for: $0) }
     let uniqueDates = Array(Set(normalizedDates)).sorted()

 var longestStreak = 1
 var streakCount = 1
 var currentStreakCount = 0

 // Check if there's a dream today or yesterday for current streak
 if let lastDate = uniqueDates.last {
 let daysSinceLastDream =
calendar.dateComponents([.day], from: lastDate, to:
today).day ?? 0
 if daysSinceLastDream <= 1 {
 currentStreakCount = 1
 }
 }

 for i in 1..<uniqueDates.count {
 let daysBetween = calendar.dateComponents([.day],
from: uniqueDates[i-1], to: uniqueDates[i]).day ?? 0

 if daysBetween == 1 {
 streakCount += 1
 longestStreak = max(longestStreak, streakCount)

 // Update current streak if this continues to today/yesterday
     if let lastDate = uniqueDates.last,
uniqueDates[i] == lastDate {
 let daysSinceLast =
calendar.dateComponents([.day], from: lastDate, to:
today).day ?? 0
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
}
struct StatCard: View {
 let value: String
 let label: String
 let icon: String
 var accentColor: Color = .white

 var body: some View {
 VStack(spacing: 8) {
 Image(systemName: icon)
 .font(.system(size: 28))
 .foregroundColor(accentColor.opacity(0.8))

 Text(value)
 .font(.system(size: 32, weight: .bold))
 .foregroundColor(.white)

 Text(label)
 .font(.caption)
 .foregroundColor(.white.opacity(0.6))
 .multilineTextAlignment(.center)
 }
 .frame(maxWidth: .infinity)
 .padding(.vertical, 20)
 .background(
 RoundedRectangle(cornerRadius: 16)
 .fill(Color.white.opacity(0.1))
 )
 }
}
func findMostCommonTags(dreams: [DreamModel]) ->
[DreamModel.Tags] {
 var tagsDict = [DreamModel.Tags: Int]()

 for d in dreams {
 for t in d.tags {
 tagsDict[t, default: 0] += 1
 }
 }
 return tagsDict.sorted { $0.value > $1.value }.map
{ $0.key }
}
func getDreamsOfCategory(dreams: [DreamModel], category:
DreamModel.Tags) -> [DreamModel] {
 return dreams.filter { dream in
 return dream.tags.contains { tag in
 return tag == category
 }
 }
}
#Preview {
 ProfileView()
}
