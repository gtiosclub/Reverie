//
//  HeatmapTags.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/15/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HeatmapTagsView: View {
    let selectedTag: DreamModel.Tags
    @State private var selectedTimeframe = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Text("Frequency in Dreams")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                }
                
                Picker("Timeframe", selection: $selectedTimeframe) {
                    Text("30 Days").tag(0)
                    Text("1 Year").tag(1)
                    Text("All").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 8)
                
                ScrollView {
                    ZStack {
                        VStack(alignment:.leading, spacing: 30) {
                            HeatmapContainerTagsView(
                                selectedTimeframe: $selectedTimeframe,
                                dreams: ProfileService.shared.dreams,
                                tag: selectedTag
                            )
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.vertical, 10)
                }
                .darkGloss()
            }
            .padding(.top, 10)
            Spacer()
        }
    }
}

struct HeatmapContainerTagsView: View {
    @Binding var selectedTimeframe: Int
    let dreams: [DreamModel]
    let tag: DreamModel.Tags
    
    private var filteredDreams: [DreamModel] {
        dreams.filter { $0.tags.contains(tag) }
    }

    private var dreamsByDate: [Date: Color] {
        var dict = [Date: Color]()
        let calendar = Calendar.current
        let colorForTag = DreamModel.tagColors(tag: tag)
        
        for dream in filteredDreams {
            let startOfDay = calendar.startOfDay(for: dream.date)
            dict[startOfDay] = colorForTag
        }
        return dict
    }
    
    var body: some View {
        Group {
            switch selectedTimeframe {
            case 0:
                MonthlyScrollTagsView(dreams: filteredDreams, dreamsByDate: dreamsByDate)
            case 1:
                YearlyScrollTagsView(dreams: filteredDreams, dreamsByDate: dreamsByDate)
            case 2:
                AllTimeScrollTagsView(dreams: filteredDreams, dreamsByDate: dreamsByDate)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal)
    }
}

struct MonthlyScrollTagsView: View {
    let dreams: [DreamModel]
    let dreamsByDate: [Date: Color]
    
    private let monthRange: [Date]
    @State private var selectedMonthIndex: Int
    
    init(dreams: [DreamModel], dreamsByDate: [Date: Color]) {
        self.dreams = dreams
        self.dreamsByDate = dreamsByDate
        
        let calendar = Calendar.current
        let lastDate = Date()
        let firstDate = calendar.date(byAdding: .day, value: -30, to: lastDate)!
        
        self.monthRange = [firstDate]
        
        self._selectedMonthIndex = State(initialValue: 0)
    }
    
    var body: some View {
        VStack {
            if !monthRange.isEmpty {
                Text(Date(), format: .dateTime.month(.wide).year())
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            TabView(selection: $selectedMonthIndex) {
                MonthlyHeatmapGridTags(month: Date(), dreamsByDate: dreamsByDate)
                    .tag(0)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 280)
        }
    }
}

struct YearlyScrollTagsView: View {
    let dreams: [DreamModel]
    let dreamsByDate: [Date: Color]
    private let currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        YearlyHeatmapGridTags(year: currentYear, dreamsByDate: dreamsByDate)
            .frame(height: 180)
    }
}

struct AllTimeScrollTagsView: View {
    let dreams: [DreamModel]
    let dreamsByDate: [Date: Color]
    
    private var yearRange: [Int] {
        let calendar = Calendar.current
        guard !dreams.isEmpty, let firstDate = dreams.min(by: { $0.date < $1.date })?.date else {
            return [calendar.component(.year, from: Date())]
        }
        let firstYear = calendar.component(.year, from: firstDate)
        let lastYear = calendar.component(.year, from: Date())
        return Array(firstYear...lastYear)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(yearRange, id: \.self) { year in
                    YearlyHeatmapGridTags(year: year, dreamsByDate: dreamsByDate)
                }
            }
        }
    }
}

struct YearlyHeatmapGridTags: View {
    let year: Int
    let dreamsByDate: [Date: Color]
    
    private let dates: [Date]
    private let monthLabels: [(month: String, weekIndex: Int)]
    
    init(year: Int, dreamsByDate: [Date: Color]) {
        self.year = year
        self.dreamsByDate = dreamsByDate
        
        let calendar = Calendar.current
        var datesArray: [Date] = []
        var labels: [(String, Int)] = []
        
        guard let yearDate = calendar.date(from: DateComponents(year: year)),
              let yearInterval = calendar.dateInterval(of: .year, for: yearDate),
              let daysInYear = calendar.dateComponents([.day], from: yearInterval.start, to: yearInterval.end).day else {
            self.dates = []
            self.monthLabels = []
            return
        }
        
        var lastMonth = -1
        for dayOffset in 0..<daysInYear {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: yearInterval.start) {
                datesArray.append(calendar.startOfDay(for: date))
                let currentMonth = calendar.component(.month, from: date)
                if currentMonth != lastMonth {
                    let weekIndex = dayOffset / 7
                    labels.append((date.formatted(.dateTime.month(.abbreviated)), weekIndex))
                    lastMonth = currentMonth
                }
            }
        }
        
        self.dates = datesArray
        self.monthLabels = labels
    }
    
    private func getTodayWeekIndex() -> Int? {
        let calendar = Calendar.current
        guard self.year == calendar.component(.year, from: Date()) else { return nil }
        
        let today = calendar.startOfDay(for: Date())
        if let dayIndexInYear = self.dates.firstIndex(of: today) {
            return dayIndexInYear / 7
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let cellSpacing: CGFloat = 6
            let cellSize: CGFloat = 15.4
            let weeksCount = Int(ceil(Double(dates.count) / 7.0))
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: cellSpacing) {
                            ForEach(0..<weeksCount, id: \.self) { weekIndex in
                                VStack(spacing: cellSpacing) {
                                    ForEach(0..<7, id: \.self) { dayIndex in
                                        let dateIndex = (weekIndex * 7) + dayIndex
                                        if dateIndex < dates.count {
                                            let date = dates[dateIndex]
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(dreamsByDate[date] ?? Color.gray.opacity(0.2))
                                                .frame(width: cellSize, height: cellSize)
                                        } else {
                                            Rectangle().fill(Color.clear).frame(width: cellSize, height: cellSize)
                                        }
                                    }
                                }
                                .id(weekIndex)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: cellSpacing) {
                            ForEach(0..<weeksCount, id: \.self) { weekIndex in
                                VStack(spacing: cellSpacing) {
                                    ForEach(0..<7, id: \.self) { dayIndex in
                                        let dateIndex = (weekIndex * 7) + dayIndex
                                        if dateIndex < dates.count {
                                            let date = dates[dateIndex]
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(dreamsByDate[date] ?? Color.gray.opacity(0.2))
                                                .frame(width: cellSize, height: cellSize)
                                        } else {
                                            Rectangle().fill(Color.clear).frame(width: cellSize, height: cellSize)
                                        }
                                    }
                                }
                                .id(weekIndex)
                            }
                        }
                    }
                }
                .onAppear {
                    if let todayWeek = getTodayWeekIndex() {
                        proxy.scrollTo(todayWeek, anchor: .trailing)
                    }
                }
            }
        }
    }
}

struct MonthlyHeatmapGridTags: View {
    let month: Date
    let dreamsByDate: [Date: Color]
    private let calendar = Calendar.current
    private let days: [Date?]
    
    init(month: Date, dreamsByDate: [Date: Color]) {
        self.month = month
        self.dreamsByDate = dreamsByDate
        
        let range = calendar.range(of: .day, in: .month, for: month)!
        let numDays = range.count
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let weekday = calendar.component(.weekday, from: firstDay) - 1
        
        var monthDays: [Date?] = Array(repeating: nil, count: weekday)
        for day in 1...numDays {
            monthDays.append(calendar.date(byAdding: .day, value: day - 1, to: firstDay))
        }
        self.days = monthDays
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(days.indices, id: \.self) { index in
                if let date = days[index] {
                    let color = dreamsByDate[date]
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color ?? Color.gray.opacity(0.2))
                        .frame(height: 35)
                        .overlay(Text("\(calendar.component(.day, from: date))").foregroundColor(.black))
                } else {
                    Rectangle().fill(Color.clear)
                }
            }
        }
    }
}

#Preview {
    HeatmapTagsView(selectedTag: .animals)
}
