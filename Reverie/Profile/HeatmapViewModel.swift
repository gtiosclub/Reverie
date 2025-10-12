//
//  HeatmapViewModel.swift
//  Reverie
//
//  Created by Suchit Vemula on 9/30/25.
//


import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class HeatmapViewModel: ObservableObject {
    
    @Published var dreams: [DreamModel] = []
    
    private let db = Firestore.firestore()

    func fetchDreams(for userID: String) async {
        let userDocRef = db.collection("USERS").document(userID)
        
        do {
            let userProfile = try await userDocRef.getDocument(as: UserProfile.self)
            
            let dreamIDs = userProfile.dreams
            print(dreamIDs)
            if dreamIDs.isEmpty {
                print("User has no dream IDs to fetch.")
                self.dreams = []
                return
            }
            
            var fetchedDreams: [DreamModel] = []
            
            for id in dreamIDs {
                do {
                    let docRef = db.collection("DREAMS").document(id)
                    let document = try await docRef.getDocument()
                    
                    let dream = try document.data(as: DreamModel.self)
                    fetchedDreams.append(dream)
                } catch {
                    print("Error fetching dream \(id): \(error)")
                }
            }
            
            self.dreams = fetchedDreams
            print("✅ Successfully fetched and updated \(dreams.count) dreams.")
        } catch {
            print("❌ Error fetching or decoding user dreams: \(error.localizedDescription)")
        }
    }
    
    struct UserProfile: Decodable {
        let dreams: [String]
    }
}
