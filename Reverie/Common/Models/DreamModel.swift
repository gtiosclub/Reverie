//
//  DreamModel.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/4/25.
//

import Foundation

class DreamModel: Decodable {
    var id: String
    var userId: String
    var date: Date
    var loggedContent: String
    var genereatedContent: String
    var tags: [Tags]
    var image: String
    var emotion: Emotions
    
    enum Tags: String, Codable, CaseIterable {
        case mountains, rivers, forests, animals, school
    }
    
    enum Emotions: String, Codable, CaseIterable {
        case happiness, sadness, anger, fear, embarrassment, anxiety
    }

    static func getTagImage(tag: Tags) -> String {
       switch tag {
           case .mountains: return "mountain.2.fill"
           case .rivers: return "figure.open.water.swim"
           case .forests: return "tree.fill"
           case .animals: return "pawprint.fill"
           case .school: return "graduationcap.fill"
       }
    }



    init(userId: String, id: String, date: Date, loggedContent: String, generatedContent:String, tags: [Tags], image: String, emotion: Emotions) {
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
