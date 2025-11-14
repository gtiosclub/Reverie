//
//  DreamFrequencyBarChartView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/14/25.
//

import SwiftUI
import Charts

struct DreamFrequencyBarChartView: View {
    var body: some View {
        let (thisMonthCount, lastMonthCount) = CleanDreamDataService.shared.monthComparison(dreams: ProfileService.shared.dreams)
        
        let barData = [
            ("This Month", thisMonthCount),
            ("Last Month", lastMonthCount)
        ]
        
        Chart {
            ForEach(barData, id: \.0) { label, count in
                BarMark(
                    x: .value("Dreams", count),
                    y: .value("Month", label)
                )
                .foregroundStyle(label == "This Month" ? .indigo : .gray.opacity(0.5))
                .cornerRadius(8)
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 200)
    }
}
