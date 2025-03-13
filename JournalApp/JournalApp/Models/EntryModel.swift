////
////  EntryModel.swift
////  JournalApp
////
////  Created by Sarah Dadoun on 2025-02-25.
////
//
import Foundation

struct Entry: Identifiable {
    var id: String
    var journalID: String
    var userID: String
    var title: String
    var content: String
    var date: Date
    var time: String
    var moods: [String]
    var mediaFiles: [String]?

    init(id: String = UUID().uuidString, journalID: String, userID: String, title: String, content: String, date: Date = Date(), moods: [String] = [], mediaFiles: [String]? = []) {
        self.id = id
        self.journalID = journalID
        self.userID = userID
        self.title = title
        self.content = content
        self.date = date
        self.time = {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            return formatter.string(from: date)
        }()
        self.moods = moods
        self.mediaFiles = mediaFiles
    }

    // Convert Firestore document into an Entry
    static func fromFirestore(document: [String: Any]) -> Entry? {
        guard let journalID = document["journalID"] as? String,
              let userID = document["userID"] as? String,
              let title = document["title"] as? String,
              let content = document["content"] as? String,
              let timestamp = document["date"] as? Double,
              let moods = document["moods"] as? [String] else {
            return nil
        }

        return Entry(
            id: document["id"] as? String ?? UUID().uuidString,
            journalID: journalID,
            userID: userID,
            title: title,
            content: content,
            date: Date(timeIntervalSince1970: timestamp),
            moods: moods,
            mediaFiles: document["mediaFiles"] as? [String] ?? []
        )
    }
}
