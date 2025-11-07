//
//  DreamDebugTest.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/27/25.
//
//
//import SwiftUI
//
//struct DreamDebugView: View {
//    private let mockDream = DreamModel(
//            userID: "mockUser",
//            id: "dream1",
//            title: "Test Dream",
//            date: Date(),
//            loggedContent: "This is a test dream content.",
//            generatedContent: "Generated content placeholder.",
//            tags: [.mountains, .rivers],
//            image: "",
//            emotion: .happiness
//        )
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Dream Debug View")
//                .font(.title)
//                .bold()
//            
//            Button("Check Current User") {
//                if let user = FirebaseLoginService.shared.currUser {
//                    print("✅ Current user exists: \(user.userID)")
//                } else {
//                    print("❌ Current user is nil! Using mock user for testing.")
//                }
//            }
//            
//            Button("Check User Dreams") {
//                let dreams = FirebaseLoginService.shared.currUser?.dreams ?? [mockDream]
//                print("User has \(dreams.count) dreams")
//                for dream in dreams {
//                    print("  - Dream ID: \(dream.id), title: \(dream.title)")
//                }
//            }
//            
//            Button("Check Filtered/Grouped Dreams") {
//                let dreams = FirebaseLoginService.shared.currUser?.dreams ?? [mockDream]
//                
//                // 1️⃣ Filtering test: non-empty titles
//                let filtered = dreams.filter { !$0.title.isEmpty }
//                print("Filtered dreams count (non-empty titles): \(filtered.count)")
//                
//                // 2️⃣ Grouping test: by month
//                let calendar = Calendar.current
//                let grouped = Dictionary(grouping: filtered) { dream -> String in
//                    let comps = calendar.dateComponents([.year, .month], from: dream.date)
//                    return "\(comps.year!)-\(comps.month!)"
//                }
//                
//                print("Grouped dreams by month keys: \(grouped.keys.sorted())")
//                for (key, group) in grouped {
//                    print("Month: \(key), dreams: \(group.map { $0.title })")
//                }
//            }
//            
//            Spacer()
//        }
//        .padding()
//    }
//    var body: some View {
//        Text("Hello")
//    }
//}
//
//#Preview {
//    DreamDebugView()
//}
