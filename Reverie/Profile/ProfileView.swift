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
                NavigationLink(destination: TestView()) {
                    Text("Test Page")
                }
            }
            TabbarView()
        }
    }
}

func findMostCommonTags(dreams: [DreamModel]) -> [DreamModel.Tags] {
    
    var tagsDict = [DreamModel.Tags: Int]()
    
    for d in dreams {
        for t in d.tags {
            tagsDict[t, default: 0] += 1
        }
    }
    return tagsDict.sorted {$0.value > $1.value}.map{$0.key}
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
