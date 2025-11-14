//
//  AvgDreamLengthBarChartView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/14/25.
//

import SwiftUI
import Charts

// dream dictionary, see AvgDreamLengthModel
let charactersPerWeek: ([AvgDreamLengthModel], Int) = AvgDreamLengthService.shared.processDreamsIntoWeeklyLengthCounts(dreams: ProfileService.shared.dreams)

struct AvgDreamLengthBarChartView: View {
    
    @State private var dreamData: [AvgDreamLengthModel] = charactersPerWeek.0
    
    @State private var last3WeeksAverage: Double = Double(charactersPerWeek.1) / AvgDreamLengthService.shared.getDreamCountForLastThreeWeeks(dreams: ProfileService.shared.dreams)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.indigo)
                        .font(Font.system(size: 14, weight: .bold))
                        .padding(.trailing, 1)
                    Text("Dream Length")
                        .foregroundColor(.indigo)
                        .font(Font.system(size: 14))
                        .bold()
                    
                    Spacer()
                }
                .padding(.top, 6)
                    
                Text(AvgDreamLengthService.shared.trendTextCharacters(allTimeAvg: AvgDreamLengthService.shared.averageCharactersPerWeek(dreams: dreamData), ThreeWeekAvg: last3WeeksAverage))
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
            DreamCharacterBarChartView(dreamData: $dreamData, last3WeeksAverage: $last3WeeksAverage)
        }
        .padding()
        .darkGloss()
    }
}

struct DreamCharacterBarChartView: View {
    @Binding var dreamData: [AvgDreamLengthModel]
    @Binding var last3WeeksAverage: Double
    
    var body: some View {
        Chart {
            ForEach(dreamData) { data in
                BarMark(
                    x: .value("Date", data.date, unit: .weekOfMonth),
                    y: .value("Characters", data.count),
                )
                .cornerRadius(5)
                .foregroundStyle(.gray.opacity(0.7))
                .foregroundStyle(by: .value("Data Type", "Weekly Characters"))
            }
            
            if last3WeeksAverage > 0 {
                let now = Date()
                let calendar = Calendar.current
                
                let endOfLine = dreamData.last?.date ?? now
                
                if let startOfLine = calendar.date(byAdding: .weekOfYear, value: -3, to: endOfLine) {
                    
                    let averageLineData = [
                        (date: startOfLine, value: last3WeeksAverage),
                        (date: endOfLine, value: last3WeeksAverage)
                    ]
                    
                    ForEach(averageLineData, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("3-Week Avg", point.value),
                            series: .value("Data", "3-Week Average")
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
        .chartLegend(.hidden)
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
    AvgDreamLengthBarChartView()
}
