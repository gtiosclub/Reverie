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

            VStack(spacing: 20) {
                Text("Activity")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                HStack(spacing: 40) {
                    StatBlock(
                        iconName: "flame.fill",
                        label: "STREAK",
                        value: "\(streak)",
                        sublabel: "days",
                        labelColor: .orange,
                        glowInner: glowInner,
                        glowOuter: glowOuter
                    )
                    StatBlock(
                        iconName: nil,
                        label: "WEEKLY AVG",
                        value: "\(weeklyAverage)",
                        sublabel: "dreams",
                        labelColor: .white.opacity(0.7),
                        glowInner: glowInner,
                        glowOuter: glowOuter
                    )
                    StatBlock(
                        iconName: nil,
                        label: "AVG LENGTH",
                        value: "\(averageLength)",
                        sublabel: "words",
                        labelColor: .white.opacity(0.7),
                        glowInner: glowInner,
                        glowOuter: glowOuter
                    )
                }
                .padding(.top, 4)

                FrequencyView()
                    .padding(.top, 16)

                Spacer()
            }
            .padding(.horizontal)
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
                        .font(.system(size: 12))
                }
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(labelColor)
            }

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: glowInner.opacity(0.9), radius: 20, x: 0, y: 0)
                    .shadow(color: glowOuter.opacity(0.9), radius: 40, x: 0, y: 0)
                    .shadow(color: glowOuter.opacity(0.7), radius: 60, x: 0, y: 0)
                    .shadow(color: glowOuter.opacity(0.5), radius: 80, x: 0, y: 0)

                Text(sublabel)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

#Preview {
    StatisticsView(streak: 2, weeklyAverage: 5, averageLength: 80)
        .background(BackgroundView())
}
