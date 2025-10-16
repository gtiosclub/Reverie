//
//  DreamArchiveView.swift
//  Reverie
//
//  Created by Artem Kim on 9/23/25.
//

import SwiftUI

struct DreamArchiveView: View {
    @State private var search = ""
    @State private var selectedTag: DreamFilterTag = .allTags
    @State private var selectedDateFilter: DateFilter = .allDates
    
    private var currentUser: UserModel? {
        FirebaseLoginService.shared.currUser
    }
    
    private var userDreams: [DreamModel] {
        currentUser?.dreams ?? []
    }
    
    private var todayDreams: [DreamModel] {
        filterDreamsByDate(userDreams, for: .today)
    }
    
    private var thisWeekDreams: [DreamModel] {
        filterDreamsByDate(userDreams, for: .thisWeek)
    }
    
    private var thisMonthDreams: [DreamModel] {
        filterDreamsByDate(userDreams, for: .thisMonth)
    }
    
    enum DreamFilterTag: String, CaseIterable, Identifiable {
        case allTags = "Tags - All"
        case love = "Love"
        case falling = "Falling"
        case beingChased = "Being Chased"
        case scared = "Scared"
        
        var id: Self { self }
    }
    
    enum DateFilter: String, CaseIterable, Identifiable {
        case allDates = "Dates - All"
        case recent = "Recent"
        case lastWeek = "Last Week"
        case lastMonth = "Last Month"
        
        var id: Self { self }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("My Dreams")
                                .bold()
                                .font(.title)
                                .foregroundColor(.white)
                            Spacer()
                            HStack(spacing: 8) {
                                Button {
                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                          //              .background(
                           //                 RoundedRectangle(cornerRadius: 8)
                          //                      .fill(.white)
                           //                     .frame(width: 32, height: 32)
                             //           )
                                }
                                
                                Button {
                                } label: {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                   //     .background(
                                    //        RoundedRectangle(cornerRadius: 8)
                                      //          .fill(.gray)
                                     //           .frame(width: //32, height: 32)
                                     //   )
                                }
                            }
                        }
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                TextField("Search", text: $search)
                            }
                            .padding(8)
                            .cornerRadius(10)
                            .glassEffect(.regular, in: .rect)
                            
                            Picker("Tags", selection: $selectedTag) {
                                ForEach(DreamFilterTag.allCases, id: \.self) { tag in
                                    Text(tag.rawValue)
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 8))
                            .accentColor(.white)
                            .glassEffect(.regular, in: .rect)
                            
                            Picker("Dates", selection: $selectedDateFilter) {
                                ForEach(DateFilter.allCases, id: \.self) { date in
                                    Text(date.rawValue)
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 8))
                            .accentColor(.white)
                            .glassEffect(.regular, in: .rect)
                        }
                    }
                    .padding()
                    .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            if !todayDreams.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Today")
                                            .font(.title2)
                                            .bold()
                                        Text(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))
                                            .font(.caption)
                                        Spacer()
                                    }
                                    
                                    VStack(spacing: 16) {
                                        ForEach(todayDreams, id: \.id) { dream in
                                            NavigationLink(destination: DreamEntryView(dream: dream)) {
                                                SectionView(
                                                    title: dream.title,
                                                    date: formatDate(dream.date),
                                                    tags: dream.tags.map { $0.rawValue.capitalized },
                                                    description: dream.loggedContent
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                            
                            if !thisWeekDreams.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("This Week")
                                        .font(.title2)
                                        .bold()
                                    VStack(spacing: 16) {
                                        ForEach(thisWeekDreams, id: \.id) { dream in
                                            NavigationLink(destination: DreamEntryView(dream: dream)) {
                                                SectionView(
                                                    title: dream.title,
                                                    date: formatDate(dream.date),
                                                    tags: dream.tags.map { $0.rawValue.capitalized },
                                                    description: dream.loggedContent
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                            
                            if !thisMonthDreams.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("This Month")
                                        .font(.title2)
                                        .bold()
                                    VStack(spacing: 16) {
                                        ForEach(thisMonthDreams, id: \.id) { dream in
                                            NavigationLink(destination: DreamEntryView(dream: dream)) {
                                                SectionView(
                                                    title: dream.title,
                                                    date: formatDate(dream.date),
                                                    tags: dream.tags.map { $0.rawValue.capitalized },
                                                    description: dream.loggedContent
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                            
                            if userDreams.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "moon.zzz")
                                        .font(.system(size: 64))
                                        .foregroundColor(.gray)
                                    Text("No dreams yet")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text("Start logging your dreams to see them here!")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 100)
                            }
                            
                            Spacer(minLength: 60)
                        }
                        .padding()
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                TabbarView()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    
    private func filterDreamsByDate(_ dreams: [DreamModel], for period: DatePeriod) -> [DreamModel] {
        let calendar = Calendar.current
        let now = Date()
        
        var startDate: Date?
        var endDate: Date?
        
        switch period {
        case .today:
            startDate = calendar.startOfDay(for: now)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)
            
        case .thisWeek:
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            let startOfSevenDaysAgo = calendar.startOfDay(for: sevenDaysAgo)
            let startOfToday = calendar.startOfDay(for: now)
            startDate = startOfSevenDaysAgo
            endDate = startOfToday
            
        case .thisMonth:
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            let startOfThirtyDaysAgo = calendar.startOfDay(for: thirtyDaysAgo)
            let startOfSevenDaysAgo = calendar.startOfDay(for: sevenDaysAgo)
            startDate = startOfThirtyDaysAgo
            endDate = startOfSevenDaysAgo
        }
        
        guard let start = startDate, let end = endDate else { return [] }
        
        return dreams
            .filter { $0.date >= start && $0.date < end }
            .sorted(by: { $0.date > $1.date })
    }

}

enum DatePeriod {
    case today
    case thisWeek
    case thisMonth
}

#Preview {
    DreamArchiveView()
}
