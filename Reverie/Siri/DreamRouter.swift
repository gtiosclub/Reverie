//
//  DreamRouter.swift
//  Reverie
//
//  Created by amber verma on 11/15/25.
//

import Foundation
import Combine

@MainActor
class DreamRouter: ObservableObject {
    static let shared = DreamRouter()

    @Published var pendingDreamText: String? = nil
    
    // Navigation fields for logging screen
    @Published var navigateToLog: Bool = false
    @Published var injectedDreamText: String = ""
    
    func navigateToLoggingView(with text: String) {
        injectedDreamText = text
        navigateToLog = true
    }
}
