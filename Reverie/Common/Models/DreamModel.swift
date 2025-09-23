//
//  DreamModel.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/4/25.
//

import Foundation

class DreamModel  {
    var id: String
    var userId: String
    var date: Date
    var loggedContent: String
    var genereatedContent: String
    var tags: [String]
    var image: String
    var emotion: Emotions


    enum Emotions {
        case sadness, joy, fear, anger, embarrassment, anxiety
    }


    init(userId: String, id: String, date: Date, loggedContent: String, generatedContent:String, tags: [String], image: String, emotion: Emotions) {
        self.userId = userId
        self.id = id
        self.date = date
        self.loggedContent = loggedContent
        self.genereatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
    }


}
