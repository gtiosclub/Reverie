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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView().ignoresSafeArea();
                VStack (spacing: 0) {
                    HStack {
                      Button(action: {
                          dismiss()
                      }) {
                          ZStack {
                              Circle()
                                  .fill(
                                      LinearGradient(
                                          colors: [
                                              Color(red: 5/255, green: 7/255, blue: 20/255),
                                              Color(red: 17/255, green: 18/255, blue: 32/255)
                                          ],
                                          startPoint: .topLeading,
                                          endPoint: .bottomTrailing
                                      )
                                  )
                                  .frame(width: 55, height: 55)
                                  .overlay(
                                      Circle()
                                          .strokeBorder(
                                              AngularGradient(
                                                  gradient: Gradient(colors: [
                                                      Color.white.opacity(0.8),
                                                      Color.white.opacity(0.1),
                                                      Color.white.opacity(0.6),
                                                      Color.white.opacity(0.1),
                                                      Color.white.opacity(0.8)
                                                  ]),
                                                  center: .center
                                              ),
                                              lineWidth: 0.5
                                          )
                                          .blendMode(.screen)
                                  )

                              Image(systemName: "chevron.left")
                                  .resizable()
                                  .scaledToFit()
                                  .frame(width: 20, height: 20)
                                  .foregroundColor(.white)
                                  .padding(.leading, -4)
                                  .bold(true)
                          }
                      }
                      .buttonStyle(.plain)
                      .padding(.leading, 8)

                      Spacer()

                      VStack(spacing: 2) {
                          Text("Themes")
                              .font(.system(size: 18, weight: .semibold))
                              .foregroundColor(.white)
                              .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.7), radius: 4)
                              .shadow(color: Color(red: 37/255, green: 23/255, blue: 79/255).opacity(0.3), radius: 8)
                      }

                      Spacer()

                      Rectangle()
                          .fill(Color.clear)
                          .frame(width: 55, height: 55)
                          .padding(.trailing, 8)
                          .opacity(0) // keeps symmetry
                  }
                  .padding(.horizontal)
                  .padding(.top, 10)
                  .padding(.bottom, 4)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            Text("This Week")
                                .foregroundStyle(.white)
                                .font(.system(size:18)).fontWeight(.semibold)
                                .padding(.horizontal)
                                .dreamGlow()
                            
                            TagViewBlock(title: "This Week", tags: thisWeekTags, isExpandable: true)
                            
                            Text("Most Common")
                                .foregroundStyle(.white)
                                .font(.system(size:18)).fontWeight(.semibold)
                                .padding(.horizontal)
                                .dreamGlow()
                            
                            TagViewBlock(title: "Most Common", tags: Array(allTags.prefix(5)), isExpandable: false)
                            
                            Text("All")
                                .foregroundStyle(.white)
                                .font(.system(size:18)).fontWeight(.semibold)
                                .padding(.horizontal)
                                .dreamGlow()
                            
                            TagViewBlock(title: "Archive", tags: allTags, isExpandable: false)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationBarHidden(true)
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
        .padding(.bottom, 10)
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
    UserTagsView().background(ProfileView())
}
