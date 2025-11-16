//
//  AnalysisView.swift
//  Reverie
//
//  Created by Isha Jain on 11/6/25.
//

import SwiftUI

struct AnalysisView: View {
    @EnvironmentObject var ts: TabState
    var currentStreak: Int {
        return ProfileService.shared.currentDreamStreak()
    }
    
    @State var dreamHealthData: [DailyHealthData] = []
    
    var body: some View {
        ZStack(alignment:.top) {
            BackgroundView()
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    AnalysisSection(
                        title: "Activity",
                        previewContent: {
                            VStack(alignment: .leading, spacing: 8) {
                                DreamFrequencyChartView(isHomeView: true)
                            }
                        },
                        destination: { StatisticsView(streak: currentStreak, weeklyAverage: ProfileService.shared.currentWeeklyAverage(), averageLength: currentAverageDreamLength) },
                        trailingView: {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("\(currentStreak) day Streak")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 4)
                            //                                .background(Color.orange.opacity(0.15))
                            //                                .cornerRadius(12)
                        }
                    )
                    //                        .padding(.top, -2)
                    
                    AnalysisSection (
                        title: "Themes",
                        //                            icon: "camera.macro",
                        previewContent: {ThisWeekThemesView(thisWeekTags: thisWeekTags)},
                        destination: {UserTagsView()},
                        trailingView: {EmptyView()}
                        
                    )
                    
                    AnalysisSection (
                        title: "Moods",
                        //                            icon: "face.smiling.fill",
                        previewContent: {HeatmapView(showSummaryText: true)},
                        destination: {CombinedHeatmapEmotionView()},
                        trailingView: {EmptyView()}
                    )
                    
                    AnalysisSection (
                        title: "Sleep",
                        previewContent: {HealthDreamChartView(dreamHealthData: $dreamHealthData, isHomeView: true)},
                        destination: {HealthView(dreamHealthData: $dreamHealthData, isHomeView: false)},
                        trailingView: {EmptyView()}
                                            //sleep view stuff here
                    )
                                        
                    //                        .padding(.bottom, 30) // test
                    
                    //                        AnalysisSection (
                    //                            title: "Sleep",
                    //                            icon: "moon.stars.fill",
                    //                            previewContent: {FrequencyView()},
                    //                            destination: {FrequencyView()},
                    //                            trailingView: {EmptyView()}
                    //                            //sleep view stuff here
                    //                        )
                }
                .padding(.top, 70)
//                .padding(.horizontal)
                .padding(.horizontal, 16)
            }
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.3),
                   Color.black.opacity(0)
               ]),
               startPoint: .top,
               endPoint: .bottom
           )
           .frame(height: 90)
           .ignoresSafeArea(edges: .top)
           .blendMode(.overlay)
                               
            HStack {
                Text("Insights")
                    .font(.custom("InstrumentSans-Bold", size: 32))
                    .foregroundColor(.white)
                Spacer()
                NavigationLink(destination: ConstellationView(dreams: ProfileService.shared.dreams, similarityMatrix: simMatrix, threshold: 0.65)) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 46/255, green: 39/255, blue: 137/255),
                                        Color(red: 64/255, green: 57/255, blue: 155/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 55, height: 55)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        AngularGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.8),
                                                Color.white.opacity(0.1),
                                                Color.white.opacity(0.6),
                                                Color.white.opacity(0.1),
                                                Color.white.opacity(0.8)
                                            ]),
                                            center: .center,
                                            startAngle: .degrees(0),
                                            endAngle: .degrees(360)
                                        ),
                                        lineWidth: 0.5
                                    )
                                    .blendMode(.screen)
                                    .shadow(color: .white.opacity(0.25), radius: 1)
                            )
                        Image(systemName: "moon.stars.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.3), radius: 4, x: 0, y: 0)
                    }
                    .padding(.trailing, 24)
                    //                        .padding(.top, 8)
                }
            }
            .padding(.leading, 17)
                       .padding(.top, 8)
                       .padding(.bottom, 40)
           .background(
               LinearGradient(
                   gradient: Gradient(stops: [
                       .init(color: DreamModel.Color(hex: "#010023"), location: 0.0),
                       .init(color: Color.clear, location: 1.0)
                   ]),
                   startPoint: .top,
                   endPoint: .bottom
               )
           )
            .task {
                do {
                    try await HealthKitChartService.shared.requestAuthorization()
                    
                    var healthData = try await HealthKitChartService.shared.fetchLast7WeeksAveraged()
                    
                    healthData = healthData.map { item in
                        var copy = item
                        copy.sleepDuration /= 3600
                        copy.remSleep /= 3600
                        return copy
                    }
                    
                    dreamHealthData = healthData
                    
                    for day in dreamHealthData {
                        print("Date:", day.date)
                        print("Sleep:", day.sleepDuration)
                        print("REM:", day.remSleep)
                        print("Steps:", day.steps)
                        print("Exercise:", day.exerciseMinutes)
                        print("Calories:", day.caloriesBurned)
                    }
                    
                } catch {
                    print("HealthKit error:", error)
                }
            }
            VStack {
                Spacer()
                TabbarView()
            }
        }
    }
}


struct AnalysisSection<Preview: View, Destination: View, Trailing: View>: View {
    let title: String
    @ViewBuilder let previewContent: () -> Preview
    @ViewBuilder let destination: () -> Destination
    @ViewBuilder var trailingView: () -> Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(title)
                    .font(.system(size:18))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .dreamGlow()
                    
                Spacer()
                trailingView()
            }
            //.padding(.horizontal)

            
            NavigationLink(destination: destination()) {
                previewContent()
                    .padding(.leading, -17)
            }
        }
    }
}

func moodSummary() -> Text {
    let baseColor = Color.white.opacity(0.8)
    
    guard let dreams = FirebaseLoginService.shared.currUser?.dreams, !dreams.isEmpty else {
        return Text("No dream data available.")
            .foregroundColor(baseColor)
    }
    
    let emotionCounts = Dictionary(grouping: dreams, by: { $0.emotion }).mapValues { $0.count }
    guard let dominantEmotion = emotionCounts.max(by: { $0.value < $1.value })?.key else {
        return Text("No dominant mood found.")
            .foregroundColor(baseColor)
    }
    
    let prefix = Text("Your average dream mood is ")
        .foregroundColor(baseColor)
    let suffix = Text(".")
        .foregroundColor(baseColor)
    let highlight = Text(dominantEmotion.rawValue.capitalized)
        .foregroundColor(DreamModel.emotionColors(emotion: dominantEmotion))
        .fontWeight(.semibold)
    
    return prefix + highlight + suffix
}

var currentAverageDreamLength: Int {
    guard let dreams = FirebaseLoginService.shared.currUser?.dreams, !dreams.isEmpty else {
        return 0
    }
    let total = dreams.reduce(0) { acc, d in
        acc + d.loggedContent.split { $0.isWhitespace || $0.isNewline }.count
    }
    return total / dreams.count
}

let simMatrix = ProfileService.shared.generateDreamsSimilarityMatrix()

#Preview {
    AnalysisView()
        .environmentObject(TabState())
}
