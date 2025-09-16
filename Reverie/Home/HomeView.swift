//
//  HomeView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct HomeView: View {
    let user = UserModel.init(name: "Brayden")
    
    var body: some View {
        NavigationStack {
            ZStack {
                StarsView()
                VStack {
                    Text("Good Morning, \(user.name)")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)
                    NewLogView()
                }
                TabbarView()
            }
        }
    }
}

#Preview {
    HomeView()
}
