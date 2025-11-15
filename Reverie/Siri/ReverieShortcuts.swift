//
//  ReverieShortcuts.swift
//  Reverie
//
//  Created by amber verma on 11/15/25.
//

import AppIntents

struct ReverieShortcuts: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogDreamIntent(),
            phrases: [
                "Log my dream in \(.applicationName)",
                "Log dream in \(.applicationName)"
            ],
            shortTitle: "Log Dream",
            systemImageName: "moon.stars"
        )
    }
}

