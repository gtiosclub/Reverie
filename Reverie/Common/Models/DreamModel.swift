//
//  DreamModel.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/4/25.
//

import Foundation
import FoundationModels


class DreamModel: Decodable {
    var id: String
    var userId: String
    var title: String
    var date: Date?
    var loggedContent: String
    var genereatedContent: String
    var tags: [Tags]
    var image: String
    var emotion: Emotions
    
    @Generable
    enum Tags: String, Codable, CaseIterable {
        case mountains, rivers, forests, animals, school
    }
    
    @Generable
    enum Emotions: String, Codable, CaseIterable {
        case happiness, sadness, anger, fear, embarrassment, anxiety, neutral
    }


    init(userId: String, id: String, title: String, date: Date, loggedContent: String, generatedContent:String, tags: [Tags], image: String, emotion: Emotions) {
        self.userId = userId
        self.id = id
        self.title = title
        self.date = date
        self.title = title
        self.loggedContent = loggedContent
        self.genereatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
    }
}
