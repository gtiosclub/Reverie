//
//  PinStore.swift
//  Reverie
//
//  Created by Joel Sari on 10/29/25.
//

import Foundation

/// PinStore is a tiny utility responsible for persisting which CardModel IDs are pinned.
///
///

enum PinStore {
    /// The key under which we store the array of pinned card IDs in UserDefaults.
    /// Using a dedicated key avoids collisions with other values you might store.
    private static let key = "pinnedCardIDs"

    /// Loads the current set of pinned card IDs from UserDefaults.
    /// - Returns: A Set<String> of pinned card IDs. Returns an empty set if nothing is stored yet.
    static func load() -> Set<String> {
        // We store as an array in UserDefaults (since it doesn't natively store Set),
        let array = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(array)
    }

    /// Persists the provided set of pinned card IDs to UserDefaults.
    static func save(_ ids: Set<String>) {
        // Convert back to an Array for UserDefaults storage.
        let array = Array(ids).sorted()
        UserDefaults.standard.set(array, forKey: key)
    }

    /// Convenience helper to check whether a given card ID is pinned.
    static func isPinned(id: String) -> Bool {
        // Load the current set and ask if it contains this id.
        return load().contains(id)
    }

    /// Toggles the pinned state for a given card ID and persists the change.
    static func toggle(id: String) {
        // Start from the current set of pinned IDs.
        var current = load()

        if current.contains(id) {
            // If it's already pinned, unpin it by removing the id from the set.
            current.remove(id)
        } else {
            // If it's not pinned, pin it by inserting the id into the set.
            current.insert(id)
        }

        // Persist the updated set back to UserDefaults.
        save(current)
    }
}
