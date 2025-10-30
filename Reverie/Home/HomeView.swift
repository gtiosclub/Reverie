//
//  HomeView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Environment(FirebaseLoginService.self) private var fls
    @Binding var isOnHomeScreen: Bool
    
    var body: some View {
        ZStack {
            MoonView()
            
            if isOnHomeScreen {
                FloatingStickersView()
                    .transition(.scale)
            }
                
                VStack {
                    Text("Good Morning, \(fls.currUser?.name ?? "Dreamer")")
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
        HomeView(isOnHomeScreen: .constant(false))
            .environment(FirebaseLoginService.shared)
    }
    
    
    

