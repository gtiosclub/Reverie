//
//  LogDreamIntent.swift
//  Reverie
//
//  Created by amber verma on 11/15/25.
//


import AppIntents

struct LogDreamIntent: AppIntent {

    static var title: LocalizedStringResource = "Log Dream"
    static var description = IntentDescription("Log a dream through Siri and open the app to edit it.")

    static var opensApplication = true

    @Parameter(title: "Dream Description")
    var dream: String

    static var parameterSummary: some ParameterSummary {
        Summary("Log my dream about \(\.$dream)")
    }

    func perform() async throws -> some IntentResult {
        print("🌀 LogDreamIntent.perform() called")
        print("📝 Dream received from Siri: \(dream)")

        await MainActor.run {
            DreamRouter.shared.pendingDreamText = dream
        }

        return .result()
    }
}


