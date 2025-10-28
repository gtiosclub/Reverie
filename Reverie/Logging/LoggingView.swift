//
//  LoggingView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct LoggingView: View {
    @State private var dream = ""
    @State private var title = ""
    @State private var date = Date()
    @State private var shouldFinishDream = false // Toggle state
    private let fms = FoundationModelService()
    
    @State private var analysis: String = ""
    @State private var emotion: DreamModel.Emotions = .neutral
    @State private var tags: [DreamModel.Tags] = []
    @State private var canNavigate = false
    @State private var finishedContent: String = "None"
    
    @State private var isLoading = false
    
    func createNotification(title: String, description: String, hour: Int, minute: Int ) {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = description
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.hour = hour
        dateComponents.minute = minute
           
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: true)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)


        let notificationCenter = UNUserNotificationCenter.current()
        Task {
            do {
                try await notificationCenter.add(request)
            } catch {
                print("notifcation error")
            }
        }
    }
 
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("notifications enabled!")
            } else if let error {
                print(error.localizedDescription)
            }
        }
        
        // TODO: Change time to what user prompts
        createNotification(title: "Good morning!", description: "Time to log your dream", hour: 18, minute: 20)
        createNotification(title: "Good Night!", description: "Dream well!", hour: 18, minute: 20)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack() {

                    HStack {
                        Toggle("Finish Dream", isOn: $shouldFinishDream)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        Spacer()
                        Button {
                            Task {
                                isLoading = true
                                
                                do {
                                    analysis = try await fms.getOverallAnalysis(dream_description: dream)
                                    emotion = try await fms.getEmotion(dreamText: dream)
                                    tags = try await fms.getRecommendedTags(dreamText: dream)
                                    finishedContent = "None"
                                    if shouldFinishDream {
                                        finishedContent = try await fms.getFinishedDream(dream_description: dream)
                                    }
                                    
                                    print(analysis, emotion, tags)
                                    canNavigate = true
                                } catch {
                                    print("Error during Foundation Model calls: \(error)")
                                }
                                
                                isLoading = false
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Circle().fill(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.9)))
                                .padding(.vertical, 4)
                                .opacity(title.isEmpty || dream.isEmpty ? 0 : 1)
                        }
                        
                        NavigationLink(destination: SaveDreamView(newDream: DreamModel(
                            userID: FirebaseLoginService.shared.currUser?.userID ?? "no id",
                            id: "blank",
                            title: title,
                            date: date,
                            loggedContent: dream,
                            generatedContent: analysis,
                            tags: tags,
                            image: "",
                            emotion: emotion,
                            finishedDream: finishedContent
                        )), isActive: $canNavigate) {
                            EmptyView()
                        }
                    }
                    
                    HStack {
                        ZStack(alignment: .leading) {
                            if title.isEmpty {
                                Text("Dream Name")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.custom("Inter", size: 30))
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            TextField("", text: $title)
                                .foregroundColor(.white)
                                .textFieldStyle(.plain)
                                .tint(.white)
                                .font(.title)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            DatePicker("", selection: $date, displayedComponents: [.date])
                                .glassEffect(.regular, in: .rect)
                                .labelsHidden()
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.white)
                        }
                    }
                    
                    ZStack(alignment: .topLeading) {
                        if dream.isEmpty {
                            Text("Start new dream entry...")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.vertical, 8)
                        }
                        TextField("", text: $dream, axis: .vertical)
                            .foregroundColor(.white)
                            .textFieldStyle(.plain)
                            .tint(.white)
                            .padding(.vertical, 8)
                    }

                    Spacer()
                }
                .padding()
                .environment(\.colorScheme, .dark)
                
                if isLoading {
                    ZStack {
                        Rectangle()
                            .fill(.black.opacity(0.6))
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("Analyzing your dream...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Material.thin)
                        )
                        .shadow(radius: 10)
                    }
                    .transition(.opacity)
                }
                
                TabbarView()
            }
        }
    }
}

#Preview {
    LoggingView()
}
