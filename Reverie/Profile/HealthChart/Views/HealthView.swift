//
//  HealthView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/16/25.
//

import SwiftUI

struct HealthView: View {
    @Binding var dreamHealthData: [DailyHealthData]
    @State var isHomeView: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                    .ignoresSafeArea()

                ScrollView {
                    VStack {
                        HealthDreamChartView(dreamHealthData: $dreamHealthData, isHomeView: isHomeView)
                    }
                    .padding()
                }
            }
            .navigationTitle("Health")
            .font(Font.system(size: 16, weight: .medium, design: .default))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    CombinedHeatmapEmotionView()
}
