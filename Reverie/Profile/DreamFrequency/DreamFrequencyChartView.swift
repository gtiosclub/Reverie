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
                    Text(CleanDreamDataService.shared.trendText(allTimeAvg: CleanDreamDataService.shared.averageDreamsPerWeek(dreams: dreamData), ThreeWeekAvg: last3WeeksAverage))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(Font.system(size: 14))
                }
//                .padding(.horizontal)
                .padding(.top, 8)
                
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
                    .padding(.horizontal, 8)
                    .padding(.top, 6)
                    .padding(.bottom, 4)
            }
            
            Chart {
                ForEach(dreamData) { data in
                    // line connecting data points
                    LineMark(
                        x: .value("Date", data.date, unit: .weekOfMonth),
                        y: .value("Dreams", data.count)
                    )
                    // line smooth and curved
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.indigo)

                    // data point
                    PointMark(
                        x: .value("Date", data.date, unit: .weekOfMonth),
                        y: .value("Dreams", data.count)
                    )
                    .foregroundStyle(.indigo)
                    .symbolSize(CGSize(width: 8, height: 8))
                }
                
                if last3WeeksAverage > 0 {
                    RuleMark(
                        y: .value("3 Week Avg", last3WeeksAverage)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(.indigo)
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
        .padding()
        .glassEffect(in: .rect)
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
}

#Preview {
    DreamFrequencyChartView()
}
