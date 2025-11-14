//
//  DreamFrequencyChartView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/13/25.
//

import SwiftUI
import Charts

// dream dictionary, see DreamFrequencyChartModel
let dreams: ([DreamFrequencyChartModel], Int) = CleanDreamDataService.shared.processDreamsIntoWeeklyCounts(dreams: ProfileService.shared.dreams)

// DEFAULT DATA
let placeholderData: [DreamFrequencyChartModel] = [
    .init(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, count: 2),
    .init(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, count: 1),
    .init(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, count: 3),
    .init(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, count: 2),
    .init(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, count: 5),
    .init(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, count: 4),
    .init(date: Date(), count: 3)
]

struct DreamFrequencyChartView: View {
    
    @State private var dreamData: [DreamFrequencyChartModel] = dreams.0
    
    @State private var last3WeeksAverage: Double = Double(dreams.1) / Double(3)
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.indigo)
                        .font(Font.system(size: 14, weight: .bold))
                        .padding(.trailing, 2)
                    Text("Dreams")
                        .foregroundColor(.indigo)
                        .font(Font.system(size: 14))
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(Font.system(size: 14))
                }
                .padding(.top, 8)
                    
                Text(CleanDreamDataService.shared.trendText(allTimeAvg: CleanDreamDataService.shared.averageDreamsPerWeek(dreams: dreamData), ThreeWeekAvg: last3WeeksAverage))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 1)
                    .padding(.horizontal, 8)
                    .padding(.top, 6)
                    .padding(.bottom, 4)
            }
            DreamChartView(dreamData: $dreamData, last3WeeksAverage: $last3WeeksAverage)
        }
        .padding()
        .darkGloss()
    }
}

struct DreamChartView: View {
    @Binding var dreamData: [DreamFrequencyChartModel]
    @Binding var last3WeeksAverage: Double
    
    var body: some View {
        Chart {
            ForEach(dreamData) { data in
                // line connecting data points
                LineMark(
                    x: .value("Date", data.date, unit: .weekOfMonth),
                    y: .value("Dreams", data.count)
                )
                // line smooth and curved
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.gray.opacity(0.7))
                
                // data point
                PointMark(
                    x: .value("Date", data.date, unit: .weekOfMonth),
                    y: .value("Dreams", data.count)
                )
                .foregroundStyle(.gray.opacity(0.7))
                .symbolSize(CGSize(width: 8, height: 8))
            }
            
            if last3WeeksAverage > 0 {
                let now = Date()
                let calendar = Calendar.current
                
                let endOfLine = now
                
                if let startOfLine = calendar.date(byAdding: .weekOfMonth, value: -3, to: endOfLine) {
                    
                    let averageLineData = [
                        (date: startOfLine, value: last3WeeksAverage),
                        (date: endOfLine, value: last3WeeksAverage)
                    ]
                    
                    ForEach(averageLineData, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("3-Week Avg", point.value),
                            series: .value("Data", "Average")
                        )
                    }
                    .foregroundStyle(.indigo)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.linear)
                    .annotation(position: .top, alignment: .trailing) {
                        Text("3-Week Avg: \(last3WeeksAverage, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.indigo)
                            .padding(.bottom, 2)
                            .bold()
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 7)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 250)
    }
}

#Preview {
    DreamFrequencyChartView()
}
