//
//  HealthChartLengendView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/16/25.
//

import SwiftUI

struct HealthChartLegendView: View {
    @Binding var selectedMetric: HealthMetric

    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(.indigo)
                    .frame(width: 10, height: 10)
                Text("Dreams per Week")
                    .font(.caption)
                    .foregroundColor(.white)
            }

            HStack(spacing: 4) {
                Circle()
                    .fill(.purple)
                    .frame(width: 10, height: 10)
                Text(selectedMetric.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.top, 6)
    }
}
