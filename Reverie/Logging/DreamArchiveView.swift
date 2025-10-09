//
//  DreamArchiveView.swift
//  Reverie
//
//  Created by Artem Kim on 9/23/25.
//

import SwiftUI

struct DreamArchiveView : View {
    @State private var search = ""
    @State private var selectedTag: Tag = .AllTags
    @State private var selectedDate: Date = .AllDates
    
    enum Tag: String, CaseIterable, Identifiable {
        case AllTags = "Tags - All", Tag1, Tag2, Tag3
        var id: Self { self }
    }
    
    enum Date: String, CaseIterable, Identifiable {
        case AllDates = "Dates - All", Date1, Date2, Date3
        var id: Self { self }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        HStack {
                            Text("My Dreams")
                                .bold()
                                .font(.title)
                            Spacer()
                            HStack {
                                Button {
                                    // TODO: Implement list button
                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.white)
                                                .frame(width: 32, height: 32)
                                        )
                                }
                                Button {
                                    // TODO: Implement calendar button
                                } label: {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.gray)
                                                .frame(width: 32, height: 32)
                                        )
                                    
                                }
                            }
                        }
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                TextField("Search", text: $search)
                            }
                            .padding(8)
                            .background(Color(.systemGray4))
                            .cornerRadius(10)
                            
                            Picker("Tags", selection: $selectedTag) {
                                ForEach(Tag.allCases, id: \.self) { tag in
                                    Text(tag.rawValue)
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray4)))
                            .accentColor(.white)
                            Picker("Dates", selection: $selectedDate) {
                                ForEach(Date.allCases, id: \.self) { date in
                                    Text(date.rawValue)
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray4)))
                            .accentColor(.white)
                        }
                        
                        HStack {
                            Text("Today")
                                .font(.title2)
                                .bold()
                                .padding(.trailing, 10)
                            Text("September 14th, 2025")
                                .font(.caption)
                            Spacer()
                        }
                        .padding(.vertical, 20)
                        Spacer()
                        
                        HStack {
                            SectionView(
                                title: "Cave Diving",
                                date: "September 14th, 2024",
                                tags: ["Love", "Falling", "Being Chased", "Scared"],
                                description: "Dream description preview Dream description preview Dream description preview Dream description preview"
                            )
                        }
                        
                        HStack {
                            Text("This Week")
                                .font(.title2)
                                .bold()
                                .padding(.trailing, 10)
                            Spacer()
                        }
                        ScrollView (.horizontal, showsIndicators: false){
                            HStack {
                                SectionView(
                                    title: "Cave Diving",
                                    date: "September 14th, 2024",
                                    tags: ["Love", "Falling", "Being Chased", "Scared"],
                                    description: "Dream description preview Dream description preview Dream description preview Dream description preview"
                                )
                                SectionView(
                                    title: "Cave Diving",
                                    date: "September 14th, 2024",
                                    tags: ["Love", "Falling", "Being Chased", "Scared"],
                                    description: "Dream description preview Dream description preview Dream description preview Dream description preview"
                                )
                                SectionView(
                                    title: "Cave Diving",
                                    date: "September 14th, 2024",
                                    tags: ["Love", "Falling", "Being Chased", "Scared"],
                                    description: "Dream description preview Dream description preview Dream description preview Dream description preview"
                                )
                            }
                        }
                        .padding(.vertical, 20)
                        Spacer()
                        
                        HStack {
                            Text("This Month")
                                .font(.title2)
                                .bold()
                                .padding(.trailing, 10)
                            Spacer()
                        }
                        ScrollView (.horizontal, showsIndicators: false) {
                            HStack {
                                SectionView(
                                    title: "Cave Diving",
                                    date: "September 14th, 2024",
                                    tags: ["Love", "Falling", "Being Chased", "Scared"],
                                    description: "Dream description preview Dream description preview Dream description preview Dream description preview"
                                )
                            }
                        }
                        .padding(.vertical, 20)
                        Spacer()
                    }
                    .padding()
                    TabbarView()
                }
            }
        }
    }
}

#Preview {
    DreamArchiveView()
}
