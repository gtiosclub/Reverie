//
//  HomeView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                StarsView()
                VStack {
                    Text("reverie home")
                }
                TabbarView()
            }
        }
    }
}

#Preview {
    HomeView()
}
