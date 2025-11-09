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
    
    @Binding var characters: [CardModel]
    
    var body: some View {
        ZStack {
            MoonView()
            FloatingStickersView(characters: characters)
            //            VStack {
            //                Text("Good Morning, \(FirebaseLoginService.shared.currUser?.name ?? "Dreamer")")
            //                    .foregroundColor(.white)
            //                    .font(.largeTitle)
            //                    .bold()
            //                    .padding(.bottom, 4)
            //                NewLogView()
            //                // UPLOADS ACHIEVEMENTS TO FIRESTORE
            ////                Button("Upload Achievements") {
            ////                    Task {
            ////                        await AchievementsService.shared.uploadAllAchievements()
            ////                    }
            ////                }
            ////                .padding()
            ////                .background(Color.blue)
            ////                .foregroundColor(.white)
            ////                .cornerRadius(8)
            //            }
            
            VStack {
                Text("Good Morning, \(FirebaseLoginService.shared.currUser?.name ?? "Dreamer")")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 4)
                Text("How did you dream last night?")
                    .foregroundColor(.white)
                    .font(.body)
                    .padding(.bottom, 19)
                NewLogView()
            }
            .padding(.bottom, 30)
        }
        .background(.clear)
//        .onReceive(NotificationCenter.default.publisher(for: .dreamCardsDidUpdate)) { _ in
//            print("HomeView received dreamCardsDidUpdate notification. Refreshing.")
//            self.characters = FirebaseLoginService.shared.currUser?.dreamCards ?? []
//        }
    }
}

    
//#Preview {
//    HomeView()
//        .environment(FirebaseLoginService.shared)
//        .background(BackgroundView())
//}
    
    
    

