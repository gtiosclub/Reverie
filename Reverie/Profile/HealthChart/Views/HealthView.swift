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
                    HStack(alignment: .center) {
                        Text("Health")
                            .font(.custom("InstrumentSans-SemiBold", size: 18))
                            .foregroundColor(.white)
                            .padding(.top, -42)
                            .dreamGlow()
                    }
                    VStack {
                        HealthDreamChartView(dreamHealthData: $dreamHealthData, isHomeView: isHomeView)
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
