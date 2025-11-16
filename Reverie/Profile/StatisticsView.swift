import SwiftUI

struct StatisticsView: View {
    let streak: Int
    let weeklyAverage: Int
    let averageLength: Int

    private let glowInner = Color(red: 31/255, green: 16/255, blue: 72/255)
    private let glowOuter = Color(red: 140/255, green: 90/255, blue: 255/255)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack (alignment: .top){
                BackgroundView()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        HStack(spacing: 56) {
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
                //.frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 10)
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
                .padding(.top, 40)
            }
            LinearGradient(
                             gradient: Gradient(colors: [
                                 Color.black.opacity(0.9),
                                 Color.black.opacity(0.6),
                                 Color.black.opacity(0.3),
                                 Color.black.opacity(0)
                             ]),
                             startPoint: .top,
                             endPoint: .bottom
                         )
                         .frame(height: 90)
                         .ignoresSafeArea(edges: .top)
                         .blendMode(.overlay)
                         
                         HStack {
                             Button(action: { dismiss() }) {
                                 ZStack {
                                     Circle()
                                         .fill(
                                             LinearGradient(
                                                 colors: [
                                                     Color(red: 5/255, green: 7/255, blue: 20/255),
                                                     Color(red: 17/255, green: 18/255, blue: 32/255)
                                                 ],
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing
                                             )
                                         )
                                         .frame(width: 55, height: 55)
                                         .overlay(
                                             Circle()
                                                 .strokeBorder(
                                                     AngularGradient(
                                                         gradient: Gradient(colors: [
                                                             Color.white.opacity(0.8),
                                                             Color.white.opacity(0.1),
                                                             Color.white.opacity(0.6),
                                                             Color.white.opacity(0.1),
                                                             Color.white.opacity(0.8)
                                                         ]),
                                                         center: .center
                                                     ),
                                                     lineWidth: 0.5
                                                 )
                                                 .blendMode(.screen)
                                         )
                                     
                                     Image(systemName: "chevron.left")
                                         .resizable()
                                         .scaledToFit()
                                         .frame(width: 20, height: 20)
                                         .foregroundColor(.white)
                                         .padding(.leading, -4)
                                         .bold(true)
                                 }
                             }
                             .buttonStyle(.plain)
                             .padding(.leading, 8)
                             
                             Spacer()
                             
                             Text("Activity")
                                 .font(.system(size: 18, weight: .semibold))
                                 .foregroundColor(.white)
                                 .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.7), radius: 4)
                                 .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.3), radius: 8)
                                 .dreamGlow()
                             
                             Spacer()
                             
                             Rectangle()
                                 .fill(Color.clear)
                                 .frame(width: 55, height: 55)
                                 .opacity(0) // keeps symmetry
                         }
                         .padding(.horizontal)
                         .padding(.top, 8)
                         .padding(.bottom, 4)
                         .background(
                             LinearGradient(
                                 gradient: Gradient(stops: [
                                     .init(color: Color(hex: "#010023"), location: 0.0),
                                     .init(color: Color.clear, location: 1.0)
                                 ]),
                                 startPoint: .top,
                                 endPoint: .bottom
                             )
                         )
                     }
                     .navigationBarHidden(true)
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
