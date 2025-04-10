//
//  JournalModel.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

import Foundation
import SwiftUI
import UIKit

struct Journal: Identifiable {
    var id: String
    var userID: String
    var title: String
    var createdAt: Date
    var entries: [String]? // List of Entry IDs (Firestore references)
    var colorHex: String

    init(
        id: String = UUID().uuidString,
        userID: String,
        title: String,
        createdAt: Date = Date(),
        entries: [String]? = [],
        colorHex: String = "#007BFF"
    ) {
        self.id = id
        self.userID = userID
        self.title = title
        self.createdAt = createdAt
        self.entries = entries
        self.colorHex = colorHex
    }

    var color: UIColor {
        return UIColor(hex: colorHex) ?? .systemBlue
    }

    var swiftUIColor: Color {
        return Color(hex: colorHex)
    }

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
            entries: document["entries"] as? [String] ?? [],
            colorHex: document["colorHex"] as? String ?? "#007BFF"
        )
        
    }
}
