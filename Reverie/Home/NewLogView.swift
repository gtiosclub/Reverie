//
//  NewLogView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/16/25.
//

import SwiftUI

struct NewLogView: View {
    
    var body: some View {
        NavigationStack {
            HStack {
                Text("New Log")
                    .font(.system(size: 18))
                    .bold()
                    .padding(.leading, 16)
                    .foregroundColor(.white)
                Spacer()
                NavigationLink {
                    LoggingView()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(.gray.opacity(0.9)))
                        .padding(.horizontal, 12)
                }
            }
            .padding()
            .frame(maxWidth: 300, minHeight: 50)
            .glassEffect(.regular, in: .rect)
            .cornerRadius(20)
            .padding(.horizontal, 50)
        }
    }
}

#Preview {
    NewLogView()
}
