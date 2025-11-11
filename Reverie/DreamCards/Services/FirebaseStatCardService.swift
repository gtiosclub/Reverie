//
//  FirebaseStatCardService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 11/10/25.
//

import Firebase
import Foundation
import FirebaseFirestore
import SwiftUI

class FirebaseStatCardService {

    private let db = Firestore.firestore()
    
    static let shared = FirebaseStatCardService()

    func fetchPreviousEightDaysDreams() async throws -> [DreamModel] {
        let dreams = FirebaseLoginService.shared.currUser?.dreams ?? []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let now = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now) else { return [] }

        let filteredDreams = dreams.compactMap { dream -> DreamModel? in
            return (dream.date >= startDate && dream.date <= now) ? dream : nil
        }
        return filteredDreams
    }
}
