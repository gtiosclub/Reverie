//
//  UserModel.swift
//  Reverie
//
//  Created by Nithya Ravula on 9/4/25.
//

import Foundation

class UserModel: Decodable {
    var name: String
    var userId: String
    var username: String
    var overallAnalysis: String
    var dreams: [DreamModel]
    
    init(name: String, userId: String, username: String, overallAnalysis: String, dreams: [DreamModel]) {
        self.name = name
        self.userId = userId
        self.username = username
        self.overallAnalysis = overallAnalysis
        self.dreams = dreams
    }
    
    init(name: String) {
        self.name = name
        self.userId = ""
        self.username = ""
        self.overallAnalysis = ""
        self.dreams = []
    }

}
