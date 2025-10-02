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
    
    let db = Firebase.db
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
        }
    }
    
    func getUserInfo() async throws -> [String] {
        let userRef = db.collection("USERS").document("OtAj4vL9Xzz8lsm4nCuL")
        print("Fetching document…")
        let snapshot = try await userRef.getDocument()
        guard let data = snapshot.data() else {
            print("No data in snapshot")
            return []
        }
        print("Document data: \(data)")
        if let dreams = data["dreams"] as? [String] {
            return dreams
        } else if let dreams = data["dreams"] as? [Any] {
            return dreams.compactMap { $0 as? String }
        }
        return []
    }
}
