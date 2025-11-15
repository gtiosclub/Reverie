//
//  DreamFrequencyBarChartView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/14/25.
//

import SwiftUI

struct DreamFrequencyBarChartView: View {
    var body: some View {
        let (thisMonthAvg, lastMonthAvg) =
            CleanDreamDataService.shared.monthComparison(dreams: ProfileService.shared.dreams)
        
        let calendar = Calendar.current
        let now = Date()
        let thisMonthName = DateFormatter().monthSymbols[calendar.component(.month, from: now) - 1]
        let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now)!
        let lastMonthName = DateFormatter().monthSymbols[calendar.component(.month, from: lastMonthDate) - 1]
        
        let barData = [
            (thisMonthName, thisMonthAvg, Color.indigo),
            (lastMonthName, lastMonthAvg, Color.gray.opacity(0.35))
        ]
        
        VStack(alignment: .leading, spacing: 24) {
            ForEach(barData, id: \.0) { label, value, color in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", value))
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Text("avg/week")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    ZStack {
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(color)
                                .frame(width: geo.size.width * CGFloat(value / max(thisMonthAvg, lastMonthAvg)), height: 30)
                        }
                        HStack {
                            Text(label)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                                .padding(.top, -6)
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(height: 160)
    }
}
