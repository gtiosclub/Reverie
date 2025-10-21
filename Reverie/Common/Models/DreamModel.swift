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
    var userID: String
    var title: String
    var date: Date
    var loggedContent: String
    var generatedContent: String
    var tags: [Tags]
    var image: String
    var emotion: Emotions
    var finishedDream: String = "None"
    
    @Generable
    enum Tags: String, Codable, CaseIterable {
        case mountains, rivers, forests, animals, school
    }
    
    @Generable
    enum Emotions: String, Codable, CaseIterable {
        case happiness, sadness, anger, fear, embarrassment, anxiety, neutral
    }





    init(userID: String, id: String, title: String, date: Date, loggedContent: String, generatedContent:String, tags: [Tags], image: String, emotion: Emotions) {
        self.userID = userID
        self.id = id
        self.title = title
        self.date = date
        self.title = title
        self.loggedContent = loggedContent
        self.generatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
        self.finishedDream = "None"
    }
    init(userID: String, id: String, title: String, date: Date, loggedContent: String, generatedContent:String, tags: [Tags], image: String, emotion: Emotions, finishedDream: String) {
        self.userID = userID
        self.id = id
        self.title = title
        self.date = date
        self.title = title
        self.loggedContent = loggedContent
        self.generatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
        self.finishedDream = finishedDream
    }
}
