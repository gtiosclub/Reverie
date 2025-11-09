//
//  ThisWeekThemesView.swift
//  Reverie
//
//  Created by Isha Jain on 11/8/25.
//
import SwiftUI

struct ThisWeekThemesView: View {
    let thisWeekTags: [DreamModel.Tags]

    var body: some View {
        TagViewBlock(title: "This Week", tags: thisWeekTags, isExpandable: true)
    }
}

#Preview {
    ThisWeekThemesView(thisWeekTags: findMostCommonTags(dreams: [d1, d2]))
}
