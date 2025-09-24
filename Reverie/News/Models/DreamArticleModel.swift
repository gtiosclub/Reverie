//
//  DreamArticleModel.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/21/25.
//

import Foundation

struct DreamArticleModel: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let image: String
    let tags: String
    let url: String
    
    init(title: String, subtitle: String?, image: String, tags: String, url: String) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.tags = tags
        self.url = url
    }
}

