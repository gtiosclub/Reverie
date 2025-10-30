//
//  FrequencyView.swift
//  Reverie
//
//  Created by Suchit Vemula on 10/14/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

private struct MonthlyDreamData {
    let month: Int
    let frequency: CGFloat
    let dominantEmotionColor: Color
}

private struct DreamGraphShape: Shape {
    var dataPoints: [CGFloat]

    func path(in rect: CGRect) -> Path {
        return Path { path in
            guard dataPoints.count > 1, let maxVal = dataPoints.max(), maxVal > 0 else {
                path.move(to: CGPoint(x: 0, y: rect.height))
                path.addLine(to: CGPoint(x: rect.width, y: rect.height))
                return
            }

            let xStep = rect.width / CGFloat(dataPoints.count - 1)
            let yStep = rect.height * 0.85 / maxVal
            let yOffset = rect.height * 0.15

            let points = dataPoints.enumerated().map { index, value in
                CGPoint(x: CGFloat(index) * xStep, y: rect.height - (value * yStep) - yOffset)
            }

            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: points[0])

            for i in 0..<points.count - 1 {
                let current = points[i]
                let next = points[i + 1]
                path.addCurve(
                    to: next,
                    control1: CGPoint(x: (current.x + next.x) / 2, y: current.y),
                    control2: CGPoint(x: (current.x + next.x) / 2, y: next.y)
                )
            }

            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.closeSubpath()
        }
    }
}

private struct PeakCircles: View {
    let data: [MonthlyDreamData]

    private var peaks: [(offset: Int, element: MonthlyDreamData)] {
        let sortedPoints = data.enumerated().sorted { $0.element.frequency > $1.element.frequency }
        return Array(sortedPoints.prefix(3).filter { $0.element.frequency > 0 })
    }

    var body: some View {
        GeometryReader { geometry in
            let frequencies = data.map { $0.frequency }
            if let maxVal = frequencies.max(), maxVal > 0 {
                let xStep = data.count > 1 ? geometry.size.width / CGFloat(data.count - 1) : geometry.size.width / 2
                let yStep = geometry.size.height * 0.85 / maxVal
                let yOffset = geometry.size.height * 0.15

                ForEach(peaks, id: \.offset) { peak in
                    let item = peak.element
                    let circleSize = 8 + (item.frequency / maxVal * 12)
                    let positionX = data.count > 1 ? CGFloat(peak.offset) * xStep : xStep
                    let position = CGPoint(
                        x: positionX,
                        y: geometry.size.height - (item.frequency * yStep) - yOffset
                    )
                    
                    Circle()
                        .fill(item.dominantEmotionColor)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(radius: 3)
                        .frame(width: circleSize, height: circleSize)
                        .position(position)
                }
            }
        }
    }
}

private struct YearlyDreamGraphView: View {
    let dreams: [DreamModel]
    let year: Int
    
    private var monthlyData: [MonthlyDreamData] {
        processDreamsForYear()
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Dream Frequency")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
                .padding(.horizontal)
            
            VStack{
                if monthlyData.contains(where: { $0.frequency > 0 }) {
                    ZStack {
                        DreamGraphShape(dataPoints: monthlyData.map { $0.frequency })
                            .fill(createGradient())
                        
                        PeakCircles(data: monthlyData)
                    }
                } else {
                    Spacer()
                    Text("No dream data for this year")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                
                Text("Jan - Dec \(String(year))")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 30)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 35/255, green: 31/255, blue: 49/255))
        .cornerRadius(10)
        .padding()
    }

    private func createGradient() -> LinearGradient {
    
        let activeMonths = monthlyData.enumerated().filter { $0.element.frequency > 0 }

        guard !activeMonths.isEmpty else {
            return LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.3)]), startPoint: .leading, endPoint: .trailing)
        }
        
        let stops = activeMonths.map { (index, data) -> Gradient.Stop in
            let location = CGFloat(index) / CGFloat(monthlyData.count - 1)
            return Gradient.Stop(color: data.dominantEmotionColor, location: location)
        }

        return LinearGradient(gradient: Gradient(stops: stops), startPoint: .leading, endPoint: .trailing)
    }

    private func processDreamsForYear() -> [MonthlyDreamData] {
        let calendar = Calendar.current
        let dreamsForYear = dreams.filter { calendar.component(.year, from: $0.date) == year }
        var results: [MonthlyDreamData] = []

        for month in 1...12 {
            let dreamsForMonth = dreamsForYear.filter { calendar.component(.month, from: $0.date) == month }
            let frequency = CGFloat(dreamsForMonth.count)
            let dominantEmotionColor: Color

            if dreamsForMonth.isEmpty {
                dominantEmotionColor = .gray.opacity(0.3)
            } else {
                let emotionCounts = Dictionary(grouping: dreamsForMonth, by: { $0.emotion }).mapValues { $0.count }
                let dominantEmotion = emotionCounts.max { $0.value < $1.value }?.key ?? .neutral
                dominantEmotionColor = dominantEmotion.color
            }
            results.append(MonthlyDreamData(month: month, frequency: frequency, dominantEmotionColor: dominantEmotionColor))
        }
        return results
    }
}

struct FrequencyView: View {
    @StateObject private var viewModel = HeatmapViewModel()
    private let yearRange = 1980...2080
    @State private var selectedPageIndex: Int

    init(){
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentYearIndex = currentYear - yearRange.lowerBound
        
        let validIndex = (0..<yearRange.count).contains(currentYearIndex) ? currentYearIndex : 0
        self._selectedPageIndex = State(initialValue: validIndex)
    }

    var body: some View {
        let years = Array(yearRange)
        TabView(selection: $selectedPageIndex) {
            ForEach(0..<years.count, id: \.self) { index in
                let year = years[index]
                YearlyDreamGraphView(dreams: viewModel.dreams, year: year)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .task{
            viewModel.fetchDreams()
        }
    }
}


#Preview {
    FrequencyView()
}
