//
//  FirebaseUserManager.swift
//  Reverie
//
//  Created by Brayden Huguenard on 9/29/25.
//

import Foundation
import Firebase
import FirebaseAuth
import Observation
import FirebaseFirestore

@MainActor
@Observable
class FirebaseUserService {
    static let shared = FirebaseUserService()
    
    var currentUser: User?
    private var handle: AuthStateDidChangeListenerHandle?
    
    var userDreams: [DreamModel] = []
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
        }
    }
    
    func fetchCurrentUserDreams() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No user is logged in.")
            return
        }
        
        do {
            let dreams = try await Firestore.firestore().collection("USERS").document(userId).collection("DREAMS").getDocuments()
            
            self.userDreams = try dreams.documents.compactMap {
                try $0.data(as: DreamModel.self)
            }
            print("Successfully fetched \(self.userDreams.count) dreams.")
        } catch {
            print("Error fetching dreams: \(error.localizedDescription)")
        }
    }
}
