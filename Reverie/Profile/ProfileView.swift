//
//  ProfileView.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/4/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                Text("reverie profile")
            }
            TabbarView()
        }
    }
}

func getDreamsOfCategory(dreams: [DreamModel], category: DreamModel.Tags) -> [DreamModel] {
    return dreams.filter { dream in
        return dream.tags.contains { tag in
            return tag == category
        }
    }
}



#Preview {
    ProfileView()
}
