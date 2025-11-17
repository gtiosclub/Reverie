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
    
    @State private var selectedThemeTags: Set<DreamModel.Tags> = []
    
    @State private var showFilters = false
    @State private var showThemesMenu = false
    @State private var showDatesMenu = false
    
    enum SortOrder {
        case newestFirst
        case oldestFirst
    }
    @State private var sortOrder: SortOrder = .newestFirst
    
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
        var dreams = userDreams
        
        if !search.isEmpty {
            dreams = dreams.filter { dream in
                dream.title.localizedCaseInsensitiveContains(search) ||
                dream.loggedContent.localizedCaseInsensitiveContains(search)
            }
        }
        
        if selectedDateFilter != .allDates,
           let (startDate, endDate) = getDateRange(for: selectedDateFilter) {
            dreams = dreams.filter { dream in
                dream.date >= startDate && dream.date <= endDate
            }
        }
        
        if !selectedThemeTags.isEmpty {
            dreams = dreams.filter { dream in
                !Set(dream.tags).isDisjoint(with: selectedThemeTags)
            }
        }
        
        dreams = dreams.sorted { a, b in
            switch sortOrder {
            case .newestFirst:
                return a.date > b.date
            case .oldestFirst:
                return a.date < b.date
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
        
        let today = filteredDreams.filter { day($0.date) == startOfToday }
        
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
        if !lastWeek.isEmpty { result.append(("This Week", lastWeek)) }
        if !lastMonth.isEmpty { result.append(("This Month", lastMonth)) }
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
                            .font(.custom("InstrumentSans-Bold", size: 32))

                            .foregroundColor(.white)
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
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(red: 15/255, green: 14/255, blue: 44/255 ))
                                )
                            }
                        }
                        .navigationBarHidden(true)
                    }
                }
                .padding()
                .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                
                ZStack(alignment: .top) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 40) {
                            Spacer(minLength: 30)
                            
                            if !groupedDreams.isEmpty {
                                ForEach(groupedDreams, id: \.title) { group in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(group.title)
                                            .font(.custom("InstrumentSans-SemiBold", size: 18))
                                            .foregroundColor(.white)
                                            .dreamGlow()
                                        
                                        Rectangle()
                                            .fill(Color.white.opacity(0.5))
                                            .frame(height: 1)
                                        
                                        ForEach(group.dreams, id: \.id) { dream in
                                            NavigationLink(
                                                destination: DreamEntryView(dream: dream, backToArchive: false)
                                            ) {
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
                            } else if search.isEmpty && selectedThemeTags.isEmpty && selectedDateFilter == .allDates {
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
                        ZStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)

                                TextField("Search", text: $search)
                                    .foregroundColor(.white)
                                    .accentColor(.white)
                            }
                            .padding(.horizontal, 15)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52.5)
                            .background(
                                Color.black.opacity(0.15)
                                    .clipShape(Capsule())
                                    .glassEffect(.regular)
                            )

                            Capsule()
                                .strokeBorder(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.9),
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.6),
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.9)
                                        ]),
                                        center: .center,
                                        startAngle: .degrees(0),
                                        endAngle: .degrees(360)
                                    ),
                                    lineWidth: 0.2
                                )
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52.5)
                        }
                        .compositingGroup()

                        .shadow(
                            color: Color(red: 60/255, green: 53/255, blue: 151/255)
                                .opacity(0.55),
                            radius: 8
                            )
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showFilters.toggle()
                            }
                        }) {
                            ZStack {
                                let filtersOff = selectedThemeTags.isEmpty && selectedDateFilter == .allDates

                                Group {
                                    if filtersOff {
                                        Color.clear
                                            .background(
                                                Color.black.opacity(0.15)
                                                    .clipShape(Circle())
                                                    .glassEffect(.regular)
                                            )
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
                                                        lineWidth: 0.4
                                                    )
                                                    .blendMode(.screen)
                                                    .shadow(color: .white.opacity(0.25), radius: 1)
                                            )
                                    } else {
                                        LinearGradient(
                                            colors: [
                                                Color(red: 46/255, green: 39/255, blue: 137/255).opacity(0.45),
                                                Color(red: 64/255, green: 57/255, blue: 155/255).opacity(0.45)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        .clipShape(Circle())
                                        .glassEffect(.regular)
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
                                    }
                                }
                                .frame(width: 52, height: 52)
                                .shadow(
                                    color: Color(red: 60/255, green: 53/255, blue: 151/255).opacity(0.55),
                                    radius: 8
                                )

                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 7)

                    }
                    .padding(.horizontal, 10)
                    .padding(.top, -3)
                }
            }
            

            
            if showFilters {
                ZStack(alignment: .topTrailing) {
                    
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                showFilters = false
                                showThemesMenu = false
                                showDatesMenu = false
                            }
                        }
                    
                    VStack(alignment: .trailing) {
                        Spacer().frame(height: 110)
                        
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 18) {
                                

                                
                                
                                Text("Filters")
                                    .font(.footnote)
                                    .foregroundColor(Color.white.opacity(0.5))
                                
                                Button {
                                    withAnimation(.easeInOut(duration: 0.18)) {
                                        showThemesMenu.toggle()
                                        if showThemesMenu { showDatesMenu = false }
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Themes")
                                                .foregroundColor(.white)
                                            
                                            if !selectedThemeTags.isEmpty {
                                                Text(selectedThemeTags.map { $0.rawValue.capitalized }
                                                    .sorted()
                                                    .joined(separator: ", "))
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(showThemesMenu ? 90 : 0))
                                    }
                                }
                                
                                if showThemesMenu {
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 14) {
                                            
                                            Button {
                                                selectedThemeTags.removeAll()
                                            } label: {
                                                HStack {
                                                    Image(systemName: selectedThemeTags.isEmpty ? "checkmark.square.fill" : "square")
                                                        .foregroundColor(.white)
                                                    Text("All")
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            
                                            ForEach(DreamModel.Tags.allCases, id: \.self) { tag in
                                                Button {
                                                    toggleTheme(tag)
                                                } label: {
                                                    HStack {
                                                        Image(systemName: selectedThemeTags.contains(tag) ? "checkmark.square.fill" : "square")
                                                            .foregroundColor(.white)
                                                        Text(tag.rawValue.capitalized)
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .frame(height: 260)
                                    .scrollIndicators(.hidden)
                                }
                                
                                Button {
                                    withAnimation(.easeInOut(duration: 0.18)) {
                                        showDatesMenu.toggle()
                                        if showDatesMenu { showThemesMenu = false }
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Dates")
                                                .foregroundColor(.white)
                                            
                                            if selectedDateFilter != .allDates {
                                                Text(dateFilterLabel(for: selectedDateFilter))
                                                    .foregroundColor(.gray)
                                                    .font(.footnote)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(showDatesMenu ? 90 : 0))
                                    }
                                }
                                
                                if showDatesMenu {
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(DateFilter.allCases) { filter in
                                            Button {
                                                selectedDateFilter = filter
                                            } label: {
                                                HStack {
                                                    Image(systemName: selectedDateFilter == filter ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(.white)
                                                    Text(dateFilterLabel(for: filter))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.leading, 4)
                                }
                                
                                Button {
                                    search = ""
                                    selectedThemeTags.removeAll()
                                    selectedDateFilter = .allDates
                                    sortOrder = .newestFirst
                                } label: {
                                    HStack {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.white)
                                        Text("Remove Filters")
                                            .foregroundColor(.white)
                                    }
                                }
                                
                            }
                            .padding(40)
                            .frame(width: 350)
                            .background(
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(Color.black.opacity(0.55))
                                    .darkGloss()
                            )



                            .padding(.trailing, 14)
                        }
                    }
                    .transition(.opacity)
                }
            }
        }

        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            ts.activeTab = .archive
            ts.showTabBar = true
        }
        .onDisappear { withAnimation(nil) { ts.showTabBar = false } }
        
        .preferredColorScheme(.dark)
        .overlay(alignment: .bottom) {
            TabbarView()
                .ignoresSafeArea(.container, edges: .bottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    
    private func toggleTheme(_ tag: DreamModel.Tags) {
        if selectedThemeTags.contains(tag) {
            selectedThemeTags.remove(tag)
        } else {
            selectedThemeTags.insert(tag)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func dateFilterLabel(for filter: DateFilter) -> String {
        switch filter {
        case .allDates: return "All"
        case .lastSevenDays: return "Last 7 Days"
        case .lastThirtyDays: return "Last 30 Days"
        case .earlier: return "Earlier"
        }
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

