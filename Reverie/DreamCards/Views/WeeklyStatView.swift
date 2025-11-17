//
//  WeeklyStatView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/10/25.
//

import SwiftUI

struct Tags: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct Emotions: Identifiable {
    let id = UUID()
    let name: String
    let percentage: Int
    let color: Color
}

struct WeeklyStatView: View {
    @Binding var dreams: [DreamModel]
    @Binding var topThemes: [Tags]
    @Binding var topMoods: [Emotions]
    @Binding var totalWordCount: Int
    @Binding var averageWordCount: Int
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 30) {
                Text("WEEKLY STATISTICS")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 24)

                HStack(spacing: 0) {
                    StatNumberView(
                        value: dreams.count,
                        label: "dreams",
                        title: "TOTAL LOGS"
                    )
                    
                    Spacer()
                    
                    let totalWordCount = dreams.reduce(0) { acc, d in
                        acc + d.loggedContent.split { $0.isWhitespace || $0.isNewline }.count
                    }

                    let averageWordCount = dreams.isEmpty ? 0 : totalWordCount / dreams.count

                    StatNumberView(
                        value: averageWordCount,
                        label: "words",
                        title: "AVG LENGTH"
                    )
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("TOP THEMES")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.7))
                    
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(topThemes.prefix(3)) { theme in
                            ThemeIconView(
                                name: theme.name,
                                icon: theme.icon,
                                color: theme.color
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("TOP MOODS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.7))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(topMoods.prefix(3)) { mood in
                            MoodRowView(
                                percentage: mood.percentage,
                                name: mood.name,
                                color: mood.color
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .padding(30)
            .frame(width: 320, height: 520)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        DreamModel.Color(hex: "#EDCAFF"),
                        DreamModel.Color(hex: "#F5E6FF")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct StatNumberView: View {
    let value: Int
    let label: String
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.7))
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.black)
                
                Text(label)
                    .font(.callout)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.top, 10)
            }
        }
    }
}

struct ThemeIconView: View {
    let name: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black.opacity(0.9))
        }
    }
}

struct MoodRowView: View {
    let percentage: Int
    let name: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(percentage)%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(width: 70, alignment: .leading)
            
            Text(name)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            Spacer()
        }
    }
}

//#Preview {
//    WeeklyStatView(dreams: $dreams, topThemes: $topThemes, topMoods: $topMoods, totalWordCount: $totalWordCount, averageWordCount: $averageWordCount)
//}
