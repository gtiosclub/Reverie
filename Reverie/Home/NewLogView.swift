//
//  NewLogView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/16/25.
//

import SwiftUI

struct NewLogView: View {
    @Binding var showLogging: Bool
    
    var body: some View {
        Button {
            showLogging = true
        } label: {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.trailing, 1)
                    .background(Circle().fill(.white.opacity(0.4)).padding(16))
                
                Text("Add dream")
                    .font(.system(size: 18))
                    .bold()
                    .padding(.leading, 5)
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: 170)
            .glassEffect(.regular, in: .rect)
            .cornerRadius(100)
            .shadow(color: .white.opacity(0.3), radius: 15, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 50)
        }
    }
}


#Preview {
    NewLogView(showLogging: .constant(false))
        .background(BackgroundView())
}
