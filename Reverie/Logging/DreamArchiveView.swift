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
    @State private var showingLogDream = false
    
    private var currentUser: UserModel? {
        FirebaseLoginService.shared.currUser
    }
    
    private var userDreams: [DreamModel] {
        currentUser?.dreams ?? []
    }
    
    enum DreamFilterTag: Identifiable, CaseIterable, Hashable {
        case allTags
        case tag(DreamModel.Tags)

        var id: String { rawValue }

        var rawValue: String {
            switch self {
            case .allTags:
                return "Tags - All"
            case .tag(let tag):
                return tag.rawValue
            }
        }

        static var allCases: [DreamFilterTag] {
            return [.allTags] + DreamModel.Tags.allCases.map { .tag($0) }
        }
    }
    
    enum DateFilter: String, CaseIterable, Identifiable {
        case allDates = "Dates - All"
        case lastSevenDays = "Last 7 Days"
        case lastThirtyDays = "Last 30 Days"
        case earlier = "Earlier"
        
        var id: Self { self }
    }
    
    private var filteredDreams: [DreamModel] {
        var dreams = userDreams.sorted(by: { $0.date > $1.date })
        
        if !search.isEmpty {
            dreams = dreams.filter { dream in
                dream.title.localizedCaseInsensitiveContains(search) ||
                dream.loggedContent.localizedCaseInsensitiveContains(search)
            }
        }
        
        if selectedDateFilter != .allDates,
           let (startDate, endDate) = getDateRange(for: selectedDateFilter) {
            dreams = dreams.filter { dream in
                return dream.date >= startDate && dream.date <= endDate
            }
        }
        
        if case .tag(let selectedTagValue) = selectedTag {
            dreams = dreams.filter { dream in
                dream.tags.contains(selectedTagValue)
            }
        }

        
        return dreams
    }
    
    private var groupedDreams: [(title: String, dreams: [DreamModel])] {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        guard !filteredDreams.isEmpty else { return [] }
        
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: startOfToday)!
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: startOfToday)!
        
        let today = filteredDreams.filter {
            calendar.isDate($0.date, inSameDayAs: now)
        }
        
        let lastWeek = filteredDreams.filter {
            $0.date >= sevenDaysAgo && $0.date < startOfToday && !calendar.isDate($0.date, inSameDayAs: now)
        }
        
        let lastMonth = filteredDreams.filter {
            $0.date >= thirtyDaysAgo && $0.date < sevenDaysAgo
        }
        
        let earlier = filteredDreams.filter {
            $0.date < thirtyDaysAgo
        }
        
        var result: [(String, [DreamModel])] = []
        if !today.isEmpty { result.append(("Today", today)) }
        if !lastWeek.isEmpty { result.append(("Last Week", lastWeek)) }
        if !lastMonth.isEmpty { result.append(("Last Month", lastMonth)) }
        if !earlier.isEmpty { result.append(("Earlier", earlier)) }
        
        return result
    }
    
    
    var body: some View {
        NavigationView {
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
                                }
                                
                                Button {
                                } label: {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                }
                                
                                NavigationLink(destination: LoggingView(), label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(.black)
                                        .padding(6)
                                        .background(Circle().fill(Color.white))
                                })
                            }
                        }
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                                TextField("Search", text: $search)
                                    .foregroundColor(.white)
                                    .accentColor(.white)
                            }
                            .padding(8)
                            .cornerRadius(10)
                            .glassEffect(.regular, in: .rect)
                            
                            Picker("Tags", selection: $selectedTag) {
                                ForEach(DreamFilterTag.allCases) { tag in
                                    Text(tag.rawValue.capitalized)
                                        .tag(tag)
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 8))
                            .accentColor(.white)
                            .colorMultiply(.white)
                            .glassEffect(.regular, in: .rect)
                            
                            Picker("Dates", selection: $selectedDateFilter) {
                                ForEach(DateFilter.allCases, id: \.self) { date in
                                    Text(date.rawValue)
                                        .foregroundColor(.white)
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 8))
                            .accentColor(.white)
                            .colorMultiply(.white)
                            .glassEffect(.regular, in: .rect)
                        }
                    }
                    .padding()
                    .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if !groupedDreams.isEmpty {
                                ForEach(groupedDreams, id: \.title) { group in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(group.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        ForEach(group.dreams, id: \.id) { dream in
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
                            } else if search.isEmpty && selectedTag == .allTags && selectedDateFilter == .allDates {
                                VStack(spacing: 16) {
                                    Image(systemName: "moon.zzz")
                                        .font(.system(size: 64))
                                        .foregroundColor(.gray)
                                    Text("No dreams yet")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    Text("Start logging your dreams to see them here!")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 100)
                            } else {
                                VStack(spacing: 16) {
                                    Image(systemName: "tray.fill")
                                        .font(.system(size: 64))
                                        .foregroundColor(.gray)
                                    Text("No Matching Dreams")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    Text("Try adjusting your filters or search terms.")
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
            .preferredColorScheme(.dark)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func getDateRange(for filter: DateFilter) -> (startDate: Date, endDate: Date)? {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        switch filter {
        case .lastSevenDays:
            guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: startOfToday) else { return nil }
            return (startDate: sevenDaysAgo, endDate: now)
            
        case .lastThirtyDays:
            guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: startOfToday) else { return nil }
            return (startDate: thirtyDaysAgo, endDate: now)
            
        case .earlier:
            guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: startOfToday) else { return nil }
            guard let arbitraryStart = calendar.date(byAdding: .year, value: -100, to: now) else { return nil }
            return (startDate: arbitraryStart, endDate: thirtyDaysAgo)
            
        case .allDates:
            return nil
        }
    }
    
}


#Preview {
    DreamArchiveView()
}
