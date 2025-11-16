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
                        VStack(spacing: 5) {
                          /*  moodSummary()
                                .font(.system(size: 14))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 18)*/
                            HeatmapView()
                            renderEmotionCircles(from: dreams)
                        }
                        .padding()
                        .padding(.top, 70)
                        //.padding(.bottom, 80)
                        //.padding(.horizontal)
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

                               // Floating nav bar
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

                                   Text("Moods")
                                       .font(.system(size: 18, weight: .semibold))
                                       .foregroundColor(.white)
                                       .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.7), radius: 4)
                                       .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.3), radius: 8)

                                   Spacer()

                                   Rectangle()
                                       .fill(Color.clear)
                                       .frame(width: 55, height: 55)
                                       .opacity(0)
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


#Preview {
    CombinedHeatmapEmotionView()
}
