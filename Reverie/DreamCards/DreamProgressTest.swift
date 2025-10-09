//
//  DreamProgressTestView.swift
//  Reverie
//
//  Created by Zhihui Chen on 9/29/25.
//

import SwiftUI

struct DreamProgressTestView: View {
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        VStack {
            DreamCardProgressView(progress: progress)
            Button("Log New Dream") {
                withAnimation(.easeInOut(duration: 1.0)) {
                    progress = min(progress + 0.2, 1.0)
                }
            }
            .padding()
        }
    }
}

#Preview {
    DreamProgressTestView()
}



