//
//  LogDreamIntent.swift
//  Reverie
//
//  Created by Artem Kim on 11/6/25.
//

import AppIntents

struct LogDreamIntent: AppIntent {
    
    static var title = LocalizedStringResource("Log a new dream")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
