//
//  UserTagsView.swift
//  Reverie
//
//  Created by Isha Jain on 10/2/25.
//

import SwiftUI

// test dreams
let d1 = DreamModel(
    userID: "hi", id: "hi", title: "Dream 1",
    date: Date(),
    loggedContent: "hi",
    generatedContent: "hi",
    tags: [.animals, .forests],
    image: ["hi"],
    emotion: .sadness,
    finishedDream: "None"
)

let d2 = DreamModel(
    userID: "hi", id: "hi", title: "Dream2",
    date: Date(),
    loggedContent: "hi",
    generatedContent: "hi",
    tags: [.mountains, .forests, .animals, .rivers, .school, .school],
    image: ["hi"],
    emotion: .happiness,
    finishedDream: "None"
)

let thisWeekDreams = getRecentDreams(dreams: FirebaseLoginService.shared.currUser?.dreams ?? [], count: 10)
let allDreams = FirebaseLoginService.shared.currUser?.dreams ?? []

let thisWeekTags: [DreamModel.Tags] = findMostCommonTags(dreams: thisWeekDreams)
let allTags: [DreamModel.Tags] = findMostCommonTags(dreams: allDreams)

struct UserTagsView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("This Week")
                        .foregroundStyle(.white)
                        .font(.largeTitle.bold())
                        .padding(.horizontal)

                    TagViewBlock(title: "This Week", tags: thisWeekTags, isExpandable: true)

                    Text("Archive")
                        .foregroundStyle(.white)
                        .font(.largeTitle.bold())
                        .padding(.horizontal)

                    TagViewBlock(title: "Archive", tags: allTags, isExpandable: false)
                }
                .padding(.bottom, 80)
            }
        }
    }
}

struct TagViewBlock: View {
    let title: String
    let tags: [DreamModel.Tags]
    let isExpandable: Bool
    
//    @State private var expanded = false
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 75))]
    }
    
//    var body: some View {
//        VStack {
//            LazyVGrid(columns: columns, spacing: 25) {
//                ForEach(displayedTags, id: \.self) { tag in
//                    NavigationLink(destination: TagInfoView(tagGiven: tag)) {
//                        TagView(tagGiven: tag)
//                        
//                    }
//                }
//            }
//            
//            if isExpandable && tags.count > collapsedTagLimit {
//                Button(action: {
//                    withAnimation {
//                        expanded.toggle()
//                    }
//                }) {
//                    Text(expanded ? "see less" : "see more")
//                        .foregroundStyle(.gray)
//                        .font(.subheadline)
//                        .padding(.top, 8)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                }
//            }
//        }
//    }
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(displayedTags, id: \.self) { tag in
                    NavigationLink(destination: TagInfoView(tagGiven: tag)) {
                        TagView(tagGiven: tag)
                    }
                }
            }
            
            if isExpandable && tags.count > collapsedTagLimit {
                NavigationLink(destination: UserTagsView()) {
//                    Text("see more")
//                        .foregroundStyle(.gray)
//                        .font(.subheadline)
//                        .padding(.top, 8)
//                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }   

    
    private var collapsedTagLimit: Int {
        // Number of tags that fit in one row
        Int(UIScreen.main.bounds.width / 100)
    }
    
    private var displayedTags: [DreamModel.Tags] {
        if isExpandable {
            return Array(tags.prefix(collapsedTagLimit))
        } else {
            return tags
        }
    }

}

#Preview {
    UserTagsView().background(ProfileView())
}
