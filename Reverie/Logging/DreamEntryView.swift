//
//  DreamEntryView.swift
//  Reverie
//
//  Created by Neel Sani on 10/2/25.
//

import SwiftUI

struct DreamEntryView: View {
    // Sample data, should be replaced with real data source
    let sampleDream: DreamModel = .init(userID: "12133", id: "78274623", title: "Hello Dream", date: Date(), loggedContent: String(repeating: "DREAM ", count: 200), generatedContent: "gen content", tags: [.animals, .forests], image: "image", emotion: .anger)
    
    var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                // Header Section (Title and Date)
                VStack(alignment: .leading, spacing: 4) {
                    Text(sampleDream.title)
                        .font(Font.title)
                        .bold()
                        .foregroundColor(.white)
                    Text(sampleDream.date.formatted())
                        .font(Font.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color(.darkGray))
                .zIndex(1) // Keep header above scrolling content
               
                // Gap for future tags (empty spacer with fixed height)
                Color(.darkGray).frame(height: 40).opacity(0)
               
                // Scrollable Dream Entry
                ScrollView {
                    Text(sampleDream.loggedContent)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                        .multilineTextAlignment(.leading)
                }
                .background(Color(.darkGray))
            }
            .background(Color(.darkGray))
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
        }
}

#Preview {
    NavigationStack {
        DreamEntryView()
            .background(Color(.darkGray))
            .navigationBarTitleDisplayMode(.inline)
    }
    
}

