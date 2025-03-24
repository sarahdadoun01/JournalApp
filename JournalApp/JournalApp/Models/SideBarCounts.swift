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
        print("🔍 Entry journalID before:", entry.journalID)
        print("📄 entry.journalID:", entry.journalID)

        counts.journalCounts[entry.journalID, default: 0] += 1

        // Tags
        for tag in entry.tags {
            print("🔍 Entry tags before:", entry.tags)
            counts.tagCounts[tag, default: 0] += 1
        }

        // Pinned
        if entry.tags.contains("pinned") { // or entry.isPinned if you track it that way
            counts.pinned += 1
        }

        // Favorites
        if entry.tags.contains("favorite") {
            counts.favorites += 1
        }

        // Deleted
        if entry.tags.contains("deleted") {
            counts.deleted += 1
        }
    }

    return counts
}
