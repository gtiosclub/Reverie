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
                "Log my dream about <dream> in \(.applicationName)",
                "In \(.applicationName) log my dream about <dream>",
                "Log dream about <dream> in \(.applicationName)",
//              "Open \(.applicationName) and log my dream about <dream>"

            ],
            shortTitle: "Log Dream",
            systemImageName: "moon.stars"
        )
    }
}

