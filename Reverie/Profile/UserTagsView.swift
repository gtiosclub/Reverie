//
//  UserTagsView.swift
//  Reverie
//
//  Created by Isha Jain on 10/2/25.
//

import SwiftUI
 


//test dreams
let d1 = DreamModel(userID: "hi", id: "hi", title: "Dream 1", date: Date(), loggedContent: "hi", generatedContent: "hi", tags: [DreamModel.Tags.animals, DreamModel.Tags.forests], image: ["hi"], emotion: DreamModel.Emotions.sadness, finishedDream: "None")

let d2 = DreamModel(userID: "hi", id: "hi", title: "Dream2", date: Date(), loggedContent: "hi", generatedContent: "hi", tags: [DreamModel.Tags.mountains, DreamModel.Tags.forests, DreamModel.Tags.animals, DreamModel.Tags.rivers, DreamModel.Tags.school, DreamModel.Tags.school], image: ["hi"], emotion: DreamModel.Emotions.happiness, finishedDream: "None")

let thisWeekDreams = getRecentDreams(dreams: FirebaseLoginService.shared.currUser?.dreams ?? [], count:  10)
let allDreams = FirebaseLoginService.shared.currUser?.dreams ?? []


let thisWeekTags: [DreamModel.Tags] = findMostCommonTags(dreams: thisWeekDreams)
let allTags: [DreamModel.Tags] = findMostCommonTags(dreams: allDreams)

struct UserTagsView: View {
    var body: some View {
        ZStack() {
            BackgroundView()
            ScrollView {
                VStack (alignment: .leading, spacing: 20) {
                    TagViewBlock(title: "This Week", tags: thisWeekTags, isExpandable: true)
                    TagViewBlock(title: "Archive", tags: allTags, isExpandable: false)
                }
            }
            .padding(.bottom, 80)
        }

    }
}

struct TagViewBlock : View {
    let title: String
    let tags: [DreamModel.Tags]
    let isExpandable: Bool
    
    @State var expanded: Bool = false;
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100))]
    }
    
    var body: some View {
        Text(title)
            .foregroundStyle(.white)
            .font(.largeTitle.bold())
            .padding(.horizontal)
        
        LazyVGrid(columns: columns, spacing: 25) {
            ForEach(displayedTags, id: \.self) { tag in
                TagView(tagGiven: tag)
            }
        }
        
        if isExpandable {
            Button(action: {
                withAnimation() {
                    expanded.toggle()
                }
            }) { Text(expanded ? "see less" : "see more")
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private var displayedTags: [DreamModel.Tags] {
        if expanded || !isExpandable {return tags}
        
        let tagsPerRow = Int(UIScreen.main.bounds.width/125)
        return Array(tags.prefix(tagsPerRow))
    }
}
#Preview {
    UserTagsView().background(ProfileView())
}
