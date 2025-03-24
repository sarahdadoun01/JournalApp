//
//  SideBarCounts.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import Foundation

struct SidebarCounts {
    var all: Int = 0
    var journalCounts: [String: Int] = [:]   // journalID count
    var tagCounts: [String: Int] = [:]       // tag name count
    var pinned: Int = 0
    var favorites: Int = 0
    var deleted: Int = 0
}

func computeSidebarCounts(from entries: [Entry]) -> SidebarCounts {
    var counts = SidebarCounts()

    for entry in entries {
        counts.all += 1

        // Journal
        counts.journalCounts[entry.journalID, default: 0] += 1

        // Tags
        for tag in entry.tags {
            counts.tagCounts[tag, default: 0] += 1
        }

        // Pinned (if you have a boolean like entry.isPinned)
        if entry.tags.contains("pinned") { // or entry.isPinned if you track it that way
            counts.pinned += 1
        }

        // Favorites (same logic)
        if entry.tags.contains("favorite") {
            counts.favorites += 1
        }

        // Deleted (if you track deleted status)
        if entry.tags.contains("deleted") {
            counts.deleted += 1
        }
    }

    return counts
}
