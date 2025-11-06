//
//  DreamModel.swift
//  Reverie
//
//  Created by Shreeya Garg on 9/4/25.
//

import Foundation
import FoundationModels
import SwiftUI


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
        case mountains, rivers, forests, animals, school, water, nature, fire, city, home, work, love, family, friends, authority, strangers, travel, chase, fight, death, fantasy, past, future, search, falling, flying, food, health, trapped, money, celebration, teeth, rooms, disasters
    }
    
    @Generable
    enum Emotions: String, Codable, CaseIterable {
        case happiness, sadness, anger, fear, embarrassment, anxiety, neutral
    }

    static func tagImages(tag: Tags) -> String {
        switch(tag) {
        case .mountains: return "mountain.2.fill"
        case .rivers: return "water.waves"
        case .forests: return "tree.fill"
        case .school: return "graduationcap.fill"
        case .flying: return "bird.fill"
        case .food: return "carrot.fill"
        case .animals: return "pawprint.fill"
        case .health: return "stethoscope.circle.fill"
        case .trapped: return "lock.fill"
        case .money: return "dollarsign.bank.building.fill"
        case .celebration: return "party.popper.fill"
        case .teeth: return "mouth.fill"
        case .rooms: return "door.left.hand.open"
        case .disasters: return "tornado.circle.fill"
        case .strangers: return "person.line.dotted.person.fill"
        case .travel: return "airplane"
        case .chase: return "figure.run"
        case .fight: return "figure.archery"
        case .death: return "exclamationmark.octagon.fill"
        case .fantasy: return "wand.and.sparkles"
        case .past: return "arrow.left.circle.fill"
        case .future: return "arrow.right.circle.fill"
        case .search: return "magnifyingglass.circle.fill"
        case .falling: return "figure.fall"
        case .water: return "drop.fill"
        case .nature: return "leaf.fill"
        case .fire: return "flame.fill"
        case .city: return "building.2.fill"
        case .home: return "house.fill"
        case .work: return "briefcase.fill"
        case .love: return "heart.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .friends: return "person.2.fill"
        case .authority: return "crown.fill"
        }
    }

    static func tagColors(tag: Tags) -> Color {
        switch tag {
        case .mountains: return Color(hex: "#724227")
        case .rivers: return Color(hex: "#779ECB")
        case .forests: return Color(hex: "#45773E")
        case .school: return Color(hex: "#5B5BE3")
        case .flying: return Color(hex: "#99D1FF")
        case .food: return Color(hex: "#DF8852")
        case .animals: return Color(hex: "#C19A6B")
        case .health: return Color(hex: "#D15B5B")
        case .trapped: return Color(hex: "#585DB2")
        case .money: return Color(hex: "#DDF2D1")
        case .celebration: return Color(hex: "#E1CB6A")
        case .teeth: return Color(hex: "#E5F99D")
        case .rooms: return Color(hex: "#93F3E3")
        case .disasters: return Color(hex: "#8690FF")
        case .strangers: return Color(hex: "#DBA5F2")
        case .travel: return Color(hex: "#C4EDFB")
        case .chase: return Color(hex: "#E971A7")
        case .fight: return Color(hex: "#C23B22")
        case .death: return Color(hex: "#C23B22")
        case .fantasy: return Color(hex: "#D291BC")
        case .past: return Color(hex: "#97693C")
        case .future: return Color(hex: "#E9936E")
        case .search: return Color(hex: "#F6C8A0")
        case .falling: return Color(hex: "#9956AF")
        case .water: return Color(hex: "#7CBAEC")
        case .nature: return Color(hex: "#A6D58D")
        case .fire: return Color(hex: "#F2B255")
        case .city: return Color(hex: "#D4D4D4")
        case .home: return Color(hex: "#FFB700")
        case .work: return Color(hex: "#8E8E8E")
        case .love: return Color(hex: "#FEBDCE")
        case .family: return Color(hex: "#83ACFF")
        case .friends: return Color(hex: "#B19ED1")
        case .authority: return Color(hex: "#F8F288")  
        }
    }

    init(userID: String, id: String, title: String, date: Date, loggedContent: String, generatedContent:String, tags: [Tags], image: String, emotion: Emotions) {
        self.userID = userID
        self.id = id
        self.title = title
        self.date = date
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
        self.loggedContent = loggedContent
        self.generatedContent = generatedContent
        self.tags = tags
        self.image = image
        self.emotion = emotion
        self.finishedDream = finishedDream
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
