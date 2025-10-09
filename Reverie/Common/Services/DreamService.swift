//
//  DreamService.swift
//  Reverie
//
//  Created by Nithya Ravula on 10/9/25.
//

import Foundation

class DreamService {
    // for methods relating to getting details from dreams
    
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
