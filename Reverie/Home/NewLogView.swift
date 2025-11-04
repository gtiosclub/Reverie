//
//  NewLogView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/16/25.
//

import SwiftUI

struct NewLogView: View {
    var body: some View {
        NavigationLink {
            LoggingView()
        } label: {
            HStack {
                Text("New Log")
                    .font(.system(size: 18))
                    .bold()
                    .padding(.leading, 16)
                
                Spacer()
                
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.trailing, 16)
                    .background(Circle().fill(.white.opacity(0.4)).padding(16))
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: 300)
            .glassEffect(.regular)
//            .glassEffect(.regular, in: .rect)
            .cornerRadius(20)
            .padding(.horizontal, 50)
        }
        .padding()
        .frame(maxWidth: 300, minHeight: 50)
        .glassEffect(.regular, in: .rect)
        .cornerRadius(20)
        .padding(.horizontal, 50)
    }
}

#Preview {
    NewLogView()
}
