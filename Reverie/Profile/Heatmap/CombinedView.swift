//
//  CombinedView.swift
//  Reverie
//
//  Created by Isha Jain on 11/8/25.
//

import SwiftUI

struct CombinedHeatmapEmotionView: View {

    let dreams: [DreamModel] = ProfileService.shared.dreams
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack (alignment: .top){
                BackgroundView()
                    .ignoresSafeArea()

                ScrollView {
                    HStack(alignment: .center) {
                        Text("Moods")
                            .font(.custom("InstrumentSans-SemiBold", size: 18))
                            .foregroundColor(.white)
                            .padding(.top, -42)
                            .dreamGlow()
                    }
                    
                    VStack(spacing: 5) {
                        HeatmapView()
                        renderEmotionCircles(from: dreams)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    CombinedHeatmapEmotionView()
}
