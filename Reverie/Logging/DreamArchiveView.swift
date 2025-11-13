//
//  DreamArchiveView.swift
//  Reverie
//
//  Created by Artem Kim on 9/23/25.
//
import SwiftUI
struct DreamArchiveView: View {
    @EnvironmentObject var ts: TabState
    
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
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: startOfToday)!
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: startOfToday)!

        guard !filteredDreams.isEmpty else { return [] }

        func day(_ date: Date) -> Date {
            calendar.startOfDay(for: date)
        }

        let today = filteredDreams.filter {
            day($0.date) == startOfToday
        }

        let lastWeek = filteredDreams.filter {
            let d = day($0.date)
            return d >= sevenDaysAgo && d < startOfToday
        }

        let lastMonth = filteredDreams.filter {
            let d = day($0.date)
            return d >= thirtyDaysAgo && d < sevenDaysAgo
        }

        let earlier = filteredDreams.filter {
            day($0.date) < thirtyDaysAgo
        }

        var result: [(String, [DreamModel])] = []
        if !today.isEmpty { result.append(("Today", today)) }
        if !lastWeek.isEmpty { result.append(("Last Week", lastWeek)) }
        if !lastMonth.isEmpty { result.append(("Last Month", lastMonth)) }
        if !earlier.isEmpty { result.append(("Earlier", earlier)) }

        return result
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundColor()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Archive")
                            .bold()
                            .font(.title)
                            .foregroundColor(.white)
                            .dreamGlow()
                        Spacer()
                        HStack(spacing: 8) {
                            
                            
                            
                            
                            NavigationLink(destination: LoggingView()) {
                                HStack {
                                    Image(systemName: "plus")
                                        .foregroundColor(Color(red: 95/255, green: 85/255, blue: 236/255 ))
                                    Text("Dream")
                                        .foregroundColor(Color(red: 95/255, green: 85/255, blue: 236/255 ))
                                        .padding(.leading, -5)
                                }
                                    .padding(7)
                                    .padding(.horizontal, 7)
                                    
                                    .background(RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(red: 15/255, green: 14/255, blue: 44/255 )))
                            }
                        }
                    }
                }
                .padding()
                .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                
                ZStack(alignment: .top) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Spacer(minLength: 30)
                            
                            if !groupedDreams.isEmpty {
                                ForEach(groupedDreams, id: \.title) { group in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(group.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Rectangle()
                                            .fill(Color.white.opacity(0.5))
                                            .frame(height: 1)
                                            .padding(.leading, 5)
                                        
                                        ForEach(group.dreams, id: \.id) { dream in
                                            NavigationLink(destination: DreamEntryView(dream: dream, backToArchive: false)) {
                                                SectionView(
                                                    title: dream.title,
                                                    date: formatDate(dream.date),
                                                    tags: dream.tags,
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
                                .padding(.top, 180)
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
                                .padding(.top, 180)
                            }
                            
                            Spacer(minLength: 80)
                        }
                        .padding()
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                            TextField("Search", text: $search)
                                .foregroundColor(.white)
                                .accentColor(.white)
                        }
                        .padding(15)
                        .cornerRadius(10)
                        .background(
                            Color.black.opacity(0.25)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .glassEffect(.regular)
                        )
                        
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.25))
                                .frame(width: 52, height: 52)
                                .glassEffect(.regular)
                            
                            Button(action: {
                                print("Filter button tapped!")
                            }) {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.leading, 7)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, -3)
                }
            }
            
            TabbarView()
                .ignoresSafeArea(edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            ts.activeTab = .archive
        }
        .preferredColorScheme(.dark)
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
            guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: startOfToday),
                  let arbitraryStart = calendar.date(byAdding: .year, value: -100, to: now) else { return nil }
            return (startDate: arbitraryStart, endDate: thirtyDaysAgo)
            
        case .allDates:
            return nil
        }
    }
}
#Preview {
    DreamArchiveView()
        .environmentObject(TabState())
}


