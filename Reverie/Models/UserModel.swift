//
//  UserModel.swift
//  Reverie
//
//  Created by Nithya Ravula on 9/4/25.
//

import Foundation

class UserModel {
    var name: String
    var userId: String
    var email: String
    var overallAnalysis: String
    var dreams: [DreamModel]
    
    init(name: String, userId: String, username: String, overallAnalysis: String, dreams: [DreamModel]) {
        self.name = name
        self.userId = userId
        self.email = username
        self.overallAnalysis = overallAnalysis
        self.dreams = []
    }

}
