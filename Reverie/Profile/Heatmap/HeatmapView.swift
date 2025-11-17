//
//  HeatmapView.swift
//  Reverie
//
//  Created by Suchit Vemula on 9/23/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

extension DreamModel.Emotions {
    var color: Color {
        switch self {
        case .sadness:
            return .blue
        case .happiness:
            return .yellow
        case .fear:
            return .purple
        case .anger:
            return .red
        case .embarrassment:
            return .orange
        case .anxiety:
            return .green
        case .neutral:
            return .white
        }
    }
}


// MARK: - Main Heatmap View
struct HeatmapView: View {
    @State private var selectedTimeframe = 1 // 0: 30 days, 1: 1 year, 2: All
    @State private var enabledEmotions: Set<DreamModel.Emotions> = Set(DreamModel.Emotions.allCases)
    
    var showSummaryText: Bool = false
    
    private let unselectedSegmentColor = Color(red: 43/255, green: 42/255, blue: 57/255)
    private let primaryPurple = Color(red: 99/255, green: 54/255, blue: 234/255)
    private let sectionColor = Color.profileContainer
    
    
    
    init(showSummaryText: Bool = false) {
        self.showSummaryText = showSummaryText
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(primaryPurple)
        UISegmentedControl.appearance().backgroundColor = UIColor(unselectedSegmentColor)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    if !showSummaryText {
                        HStack {
                            moodSummary()
                                .font(.subheadline)
//                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                                
            
                        Picker("Timeframe", selection: $selectedTimeframe) {
                            Text("30 Days").tag(0)
                            Text("1 Year").tag(1)
                            Text("All").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                        .padding(.bottom, 8)
                    }
                    
                    ZStack {
//                        RoundedRectangle(cornerRadius: 18)
//                            .fill(sectionColor)
                        VStack(alignment: .leading, spacing: 10) {
                            if showSummaryText {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        moodSummary()
                                            .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(Font.system(size: 14))
                                        
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                    .padding(.bottom, 3)
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 1)
                                        .padding(.horizontal, 8)
                                        .padding(.top, 6)
                                        .padding(.bottom, 4)
                                }
                            }
   
                            VStack(alignment:.leading) {
                                HeatmapContainerView(
                                    selectedTimeframe: $selectedTimeframe,
                                    dreams: ProfileService.shared.dreams,
                                    enabledEmotions: $enabledEmotions
                                )

                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .darkGloss()
                    
                                        
                    if !showSummaryText {
                        EmotionLegendView(enabledEmotions: $enabledEmotions)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .center)                  }
                }
//                .padding(.top, 15)
            }
        }
    }}
    
    // MARK: - Heatmap Container (Handles different timeframe views)
    struct HeatmapContainerView: View {
        @Binding var selectedTimeframe: Int
        let dreams: [DreamModel]
        @Binding var enabledEmotions: Set<DreamModel.Emotions>
        
        private var filteredDreams: [DreamModel] { // **NEW COMPUTED PROPERTY**
                dreams.filter { enabledEmotions.contains($0.emotion) }
            }
        private var dreamsByDate: [Date: DreamModel.Emotions] {
            var dict = [Date: DreamModel.Emotions]()
            let calendar = Calendar.current
            for dream in filteredDreams {
                let startOfDay = calendar.startOfDay(for: dream.date)
                dict[startOfDay] = dream.emotion
            }
            return dict
        }
        
        var body: some View {
            Group {
                switch selectedTimeframe {
                case 0:
                    MonthlyScrollView(dreams: filteredDreams, dreamsByDate: dreamsByDate)
                case 1:
                    YearlyScrollView(dreams: filteredDreams, dreamsByDate: dreamsByDate)
                case 2:
                    AllTimeScrollView(dreams: filteredDreams, dreamsByDate: dreamsByDate)
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Monthly Scroll View (30 Day Option)
    struct MonthlyScrollView: View {
        let dreams: [DreamModel]
        let dreamsByDate: [Date: DreamModel.Emotions]
        
        private let monthRange: [Date]
        @State private var selectedMonthIndex: Int
        
        init(dreams: [DreamModel], dreamsByDate: [Date: DreamModel.Emotions]) {
            self.dreams = dreams
            self.dreamsByDate = dreamsByDate
            
            let calendar = Calendar.current
            let firstDate = dreams.min(by: { $0.date < $1.date })?.date ?? Date()
            let lastDate = Date() // Today
            
            var months: [Date] = []
            var currentDate = calendar.date(from: calendar.dateComponents([.year, .month], from: firstDate))!
            let endDate = calendar.date(from: calendar.dateComponents([.year, .month], from: lastDate))!
            
            while currentDate <= endDate {
                months.append(currentDate)
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
            }
            self.monthRange = months
            self._selectedMonthIndex = State(initialValue: max(0, months.count - 1))
        }
        
        var body: some View {
            VStack {
                if !monthRange.isEmpty {
                    Text(monthRange[selectedMonthIndex], format: .dateTime.month(.wide).year())
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                TabView(selection: $selectedMonthIndex) {
                    ForEach(monthRange.indices, id: \.self) { index in
                        MonthlyHeatmapGrid(month: monthRange[index], dreamsByDate: dreamsByDate)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 280)
            }
        }
    }
    
    // MARK: - Yearly Scroll View (1 Year Option)
    struct YearlyScrollView: View {
        let dreams: [DreamModel]
        let dreamsByDate: [Date: DreamModel.Emotions]
        private let currentYear = Calendar.current.component(.year, from: Date())
        
        var body: some View {
            YearlyHeatmapGrid(year: currentYear, dreamsByDate: dreamsByDate)
                .frame(height: 180)
        }
    }
    
    // MARK: - All Time Scroll View (All Option)
    struct AllTimeScrollView: View {
        let dreams: [DreamModel]
        let dreamsByDate: [Date: DreamModel.Emotions]
        
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
                        YearlyHeatmapGrid(year: year, dreamsByDate: dreamsByDate)
                    }
                }
            }
        }
    }
    
    // MARK: - Yearly Heatmap Grid
    struct YearlyHeatmapGrid: View {
        let year: Int
        let dreamsByDate: [Date: DreamModel.Emotions]
        
        private let dates: [Date]
        private let monthLabels: [(month: String, weekIndex: Int)]
        
        init(year: Int, dreamsByDate: [Date: DreamModel.Emotions]) {
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
//                Text(String(year))
//                    .font(.headline)
//                    .foregroundColor(.white)
                
                let cellSpacing: CGFloat = 6
                let cellSize: CGFloat = 15.4
                let weeksCount = Int(ceil(Double(dates.count) / 7.0))
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 5) {
                            // Month Labels
                            HStack(spacing: cellSpacing) {
                                ForEach(0..<weeksCount, id: \.self) { weekIndex in
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: cellSize, height: 10)
                                        .overlay(alignment: .leading) {
                                            if let month = monthLabels.first(where: { $0.weekIndex == weekIndex })?.month {
                                                Text(month)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .fixedSize()
                                            }
                                        }
                                }
                            }
                            
                            // Grid
                            HStack(alignment: .top, spacing: cellSpacing) {
                                ForEach(0..<weeksCount, id: \.self) { weekIndex in
                                    VStack(spacing: cellSpacing) {
                                        ForEach(0..<7, id: \.self) { dayIndex in
                                            let dateIndex = (weekIndex * 7) + dayIndex
                                            if dateIndex < dates.count {
                                                let date = dates[dateIndex]
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(dreamsByDate[date]?.color ?? Color.gray.opacity(0.2))
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
    
    // MARK: - Monthly Heatmap Grid
    struct MonthlyHeatmapGrid: View {
        let month: Date
        let dreamsByDate: [Date: DreamModel.Emotions]
        private let calendar = Calendar.current
        private let days: [Date?]
        
        init(month: Date, dreamsByDate: [Date: DreamModel.Emotions]) {
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
                        let emotion = dreamsByDate[date]
                        RoundedRectangle(cornerRadius: 4)
                            .fill(emotion?.color ?? Color.gray.opacity(0.2))
                            .frame(height: 35)
                            .overlay(Text("\(calendar.component(.day, from: date))").foregroundColor(.black))
                    } else {
                        Rectangle().fill(Color.clear)
                    }
                }
            }
        }
    }
    
    // MARK: - Emotion Legend View
struct EmotionLegendView: View {
    @Binding var enabledEmotions: Set<DreamModel.Emotions>
    
    private func toggleEmotion(_ emotion: DreamModel.Emotions) {
        if enabledEmotions.contains(emotion) {
            enabledEmotions.remove(emotion)
        } else {
            enabledEmotions.insert(emotion)
        }
    }
    
    let emotions: [DreamModel.Emotions] = [.sadness, .happiness, .fear, .anger, .embarrassment, .anxiety, .neutral]
    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 120), spacing: 10, alignment: .leading)]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            ForEach(emotions.indices, id: \.self) { index in
                let emotion = emotions[index]
                let isEnabled = enabledEmotions.contains(emotion)
                
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(emotions[index].color)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Group {
                                if isEnabled {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .foregroundColor(.black)
                                        .scaledToFit()
                                        .padding(4)
                                }
                            }
                        )
                    
                    Text(String(describing: emotions[index]).capitalized)
                    //                            .font(.subheadline)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.15)) {
                        toggleEmotion(emotion)
                    }
                }
            }
        }
    }
}

#Preview {
    HeatmapView()
}
