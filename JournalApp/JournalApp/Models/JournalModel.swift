//
//  JournalModel.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

import Foundation

struct Journal: Identifiable {
    var id: String
    var userID: String
    var title: String
    var createdAt: Date
    var entries: [String]? // List of Entry IDs (Firestore references)

    init(id: String = UUID().uuidString, userID: String, title: String, createdAt: Date = Date(), entries: [String]? = []) {
        self.id = id
        self.userID = userID
        self.title = title
        self.createdAt = createdAt
        self.entries = entries
    }

    // Convert Firestore document into a Journal
    static func fromFirestore(document: [String: Any]) -> Journal? {
        guard let userID = document["userID"] as? String,
              let title = document["title"] as? String,
              let timestamp = document["createdAt"] as? Double else {
            return nil
        }

        return Journal(
            id: document["id"] as? String ?? UUID().uuidString,
            userID: userID,
            title: title,
            createdAt: Date(timeIntervalSince1970: timestamp),
            entries: document["entries"] as? [String] ?? []
        )
    }
}

