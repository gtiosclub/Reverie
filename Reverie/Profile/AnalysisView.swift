//
//  AnalysisView.swift
//  Reverie
//
//  Created by Isha Jain on 11/6/25.
//

import SwiftUI

struct AnalysisView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment:.top) {
                BackgroundView()
                    .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    AnalysisSection (
                        title: "Activity",
                        icon: "cloud.fill",
                        content: {HeatmapView()}
                    )
                    
                    AnalysisSection (
                        title: "Themes",
                        icon: "camera.macro",
                        content: {HeatmapView()}
                    )
                    
                    AnalysisSection (
                        title: "Moods",
                        icon: "face.smiling.fill",
                        content: {HeatmapView()}
                    )
                    
                    AnalysisSection (
                        title: "Sleep",
                        icon: "moon.stars.fill",
                        content: {HeatmapView()}
                    )
                }
                   .padding(.top, 75)
                   .padding(.horizontal)
                   .padding(.bottom)
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
                  Text("Analysis")
                      .font(.largeTitle.bold())
                      .foregroundColor(.white)
                  Spacer()
              }
              .padding(.leading, 32)
              .padding(.top, 12)
          }
          .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct AnalysisSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
            Section {
                NavigationLink(destination: content()) {
                    content()
                }
            } header: {
                Label {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
            }
        }
}

#Preview {
    AnalysisView()
        
}
