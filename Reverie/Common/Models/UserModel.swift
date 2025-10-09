//
//  UserModel.swift
//  Reverie
//
//  Created by Nithya Ravula on 9/4/25.
//

import Foundation


class UserModel: Decodable {
    var name: String
    var userID: String
    var username: String
    var overallAnalysis: String
    var dreams: [DreamModel]
    
    init(name: String, userID: String, username: String, overallAnalysis: String, dreams: [DreamModel]) {
        self.name = name
        self.userID = userID
        self.username = username
        self.overallAnalysis = overallAnalysis
        self.dreams = dreams
    }
    
    init(name: String) {
        self.name = name
        self.userID = ""
        self.username = ""
        self.overallAnalysis = ""
        self.dreams = []
    }

}
