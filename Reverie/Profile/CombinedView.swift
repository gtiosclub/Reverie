//
//  CombinedView.swift
//  Reverie
//
//  Created by Isha Jain on 11/8/25.
//

import SwiftUI

struct CombinedHeatmapEmotionView: View {
    let dreams: [DreamModel] = ProfileService.shared.dreams

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 5) {
                        HeatmapView()
                        renderEmotionCircles(from: dreams)
                    }
                    .padding()
                }
            }
            .navigationTitle("Mood")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    CombinedHeatmapEmotionView()
}
