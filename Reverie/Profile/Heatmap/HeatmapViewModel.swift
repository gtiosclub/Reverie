//
//  HeatmapViewModel.swift
//  Reverie
//
//  Created by Suchit Vemula on 9/30/25.
//


//import SwiftUI
//import Combine
//import FirebaseFirestore
//import FirebaseAuth
//
//@MainActor
//class HeatmapViewModel: ObservableObject {
//    
//    @Published var dreams: [DreamModel] = []
//    
//    func fetchDreams() {
//        guard let user = FirebaseLoginService.shared.currUser else {
//            print("No current user found")
//            return
//        }
//        self.dreams = user.dreams
//        return
//    }
//    
//    struct UserProfile: Decodable {
//        let dreams: [String]
//    }
//}
