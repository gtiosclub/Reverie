//
//  ProfileService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/14/25.
//

import Foundation
import SwiftUI

class ProfileService {
    static let shared = ProfileService()
    @State var dreams: [DreamModel] = FirebaseLoginService.shared.currUser?.dreams ?? []
    
    func currentDreamStreak() -> Int {
        guard !dreams.isEmpty else { return 0 }
        let cal = Calendar.current
        // Deduplicate to unique days
        let uniqueDays = Set(dreams.map { cal.startOfDay(for: $0.date) })
        guard let mostRecent = uniqueDays.max() else { return 0 }

        var streak = 1
        var cursor = mostRecent
        while let prev = cal.date(byAdding: .day, value: -1, to: cursor), uniqueDays.contains(prev) {
            streak += 1
            cursor = prev
        }
        return streak
    }
    
    func currentWeeklyAverage() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let recentDreams = dreams.filter { $0.date >= oneWeekAgo }
        return recentDreams.count
    }
}
