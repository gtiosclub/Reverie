//
//  HomeView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    //    @Environment(FirebaseLoginService.self) private var fls
    
    var body: some View {
        ZStack {
            MoonView()
            FloatingStickersView()
            VStack {
                Text("Good Morning, \(FirebaseLoginService.shared.currUser?.name ?? "Dreamer")")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                NewLogView()
            }
            .padding(.bottom, 30)
        }
        .background(.clear)
    }
}
    
#Preview {
    HomeView()
        .environment(FirebaseLoginService.shared)
}
    
    
    

