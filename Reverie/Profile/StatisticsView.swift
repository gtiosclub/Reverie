import SwiftUI

struct StatisticsView: View {
    let streak: Int
    let weeklyAverage: Int
    let averageLength: Int

    private let glowInner = Color(red: 31/255, green: 16/255, blue: 72/255)
    private let glowOuter = Color(red: 140/255, green: 90/255, blue: 255/255)

    var body: some View {
        ZStack {
            BackgroundView()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Activity")
                        .font(Font.system(size: 20, weight: .medium, design: .default))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 60) {
                        StatBlock(
                            iconName: "flame.fill",
                            label: "STREAK",
                            value: "\(streak)",
                            sublabel: streak == 1 ? "day" : "days",
                            labelColor: .orange,
                            glowInner: glowInner,
                            glowOuter: glowOuter
                        )
                        StatBlock(
                            iconName: nil,
                            label: "WEEKLY AVG",
                            value: "\(weeklyAverage)",
                            sublabel: weeklyAverage == 1 ? "dream" : "dreams",
                            labelColor: .white.opacity(0.7),
                            glowInner: glowInner,
                            glowOuter: glowOuter
                        )
                        StatBlock(
                            iconName: nil,
                            label: "AVG LENGTH",
                            value: "\(averageLength)",
                            sublabel: averageLength == 1 ? "word" : "words",
                            labelColor: .white.opacity(0.7),
                            glowInner: glowInner,
                            glowOuter: glowOuter
                        )
                    }
                    .padding(.top, 10)
                    
                    //                FrequencyView()
                    VStack(spacing: 16) {
                        DreamFrequencyChartView(isHomeView: false)
                            .padding(.top, 4)
                        
                        AvgDreamLengthBarChartView()
                        
                        DreamFrequencyChartView(isHomeView: false, isBar: true)
                    }
                    
                    Spacer()
                }
                .padding(.top, -42)
                .padding(.horizontal)
            }
        }
    }
}

struct StatBlock: View {
    let iconName: String?
    let label: String
    let value: String
    let sublabel: String
    let labelColor: Color
    let glowInner: Color
    let glowOuter: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .foregroundColor(labelColor)
                        .font(.system(size: 15))
                }
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(labelColor)
            }
            .shadow(color: labelColor, radius: 8)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: glowOuter, radius: 5)

                Text(sublabel)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .shadow(color: glowOuter, radius: 5)
            }
        }
    }
}

#Preview {
    StatisticsView(streak: 2, weeklyAverage: 5, averageLength: 80)
        .background(BackgroundView())
}
