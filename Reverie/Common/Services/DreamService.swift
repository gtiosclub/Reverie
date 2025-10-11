//
//  DreamService.swift
//  Reverie
//
//  Created by Nithya Ravula on 10/9/25.
//

import Foundation

@MainActor
class DreamService {
    // for methods relating to getting details from dreams
    static let shared = DreamService()
    
    func sortByDate(startDate: Date, endDate: Date) -> [DreamModel] {
        guard let user = FirebaseLoginService.shared.currUser else {
            print("No current user found")
            return []
        }
        
        let filteredDreams = user.dreams.filter { dream in
            return dream.date >= startDate && dream.date <= endDate
        }
        
        return filteredDreams
    }
    
    func getTags(from dream: DreamModel) -> [DreamModel.Tags] {
            return dream.tags
    
    func sortByTags(tag: DreamModel.Tags) -> [DreamModel] {
        var dreams: [DreamModel] = []
        let user = FirebaseLoginService.shared.currUser
        let dreamList = user?.dreams ?? []
        
        for dream in dreamList {
            for dreamTag in dream.tags {
                if dreamTag == tag {
                    dreams.append(dream)
                }
            }
        }
        return dreams;
    }
}



