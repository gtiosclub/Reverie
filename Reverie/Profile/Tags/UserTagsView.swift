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
let allDreams = ProfileService.shared.dreams

let thisWeekTags: [DreamModel.Tags] = findMostCommonTags(dreams: thisWeekDreams)
let allTags: [DreamModel.Tags] = findMostCommonTags(dreams: allDreams)

struct UserTagsView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                HStack(alignment: .center) {
                    Text("Themes")
                        .font(.custom("InstrumentSans-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .padding(.top, -42)
                        .dreamGlow()
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Recent")
                        .foregroundStyle(.white)
                        .font(Font.system(size: 20, weight: .medium, design: .default))
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .dreamGlow()

                    TagViewBlock(title: "This Week", tags: thisWeekTags, isExpandable: true)
                        .padding(.leading, 32)
                    
                    Text("Most Common")
                        .foregroundStyle(.white)
                        .font(Font.system(size: 20, weight: .medium, design: .default))
                        .padding(.horizontal)
                        .dreamGlow()
                    
                    TagViewBlock(title: "Most Common", tags: Array(allTags.prefix(5)), isExpandable: false)
                        .padding(.leading, 32)

                    Text("All")
                        .foregroundStyle(.white)
                        .font(Font.system(size: 20, weight: .medium, design: .default))
                        .padding(.horizontal)
                        .dreamGlow()

                    TagViewBlock(title: "Archive", tags: allTags, isExpandable: false)
                        .padding(.leading, 32)
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
    var limitToFirstRow: Bool = false
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 75))]
    }
    
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
                }
            }
        }
    }

    
    private var collapsedTagLimit: Int {
        // Number of tags that fit in one row
        Int(UIScreen.main.bounds.width / 110)
    }
    
    private var displayedTags: [DreamModel.Tags] {
            if limitToFirstRow {
                return Array(tags.prefix(collapsedTagLimit))
            } else if isExpandable {
                return Array(tags.prefix(collapsedTagLimit))
            } else {
                return tags
            }
        }
    }

#Preview {
    UserTagsView()
}
