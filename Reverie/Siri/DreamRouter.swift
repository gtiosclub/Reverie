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
    
    @Published var navigateToLog: Bool = false
    @Published var injectedDreamText: String = ""
    
    func navigateToLoggingView(with text: String) {
        print("🚀 DreamRouter.navigateToLoggingView called")
            print("➡️ Injecting text: \(text)")
            injectedDreamText = text
            navigateToLog = true
            print("📍 navigateToLog set to TRUE")
    }
}
