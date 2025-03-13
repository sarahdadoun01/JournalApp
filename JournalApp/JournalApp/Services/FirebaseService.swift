//
//  FirebaseService.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage


@MainActor
class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    
    // Test firebase connection
    func testFirestoreConnection() async {
        let testDoc = db.collection("test").document("testDoc")
        
        do {
            try await testDoc.setData(["message": "Hello, Firebase!"])
            print("✅ Firestore is connected successfully!")
        } catch {
            print("❌ Firestore connection failed: \(error.localizedDescription)")
        }
    }
    
//    func fetchJournals(userID: String, completion: @escaping ([Journal]) -> Void) {
//        db.collection("journals")
//            .whereField("userID", isEqualTo: userID)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ Error fetching journals: \(error.localizedDescription)")
//                    completion([])
//                    return
//                }
//
//                let journals = snapshot?.documents.compactMap { document -> Journal? in
//                    let data = document.data()
//                    guard let title = data["title"] as? String else { return nil }
//
//                    return Journal(
//                        id: document.documentID,
//                        userID: userID,
//                        title: title
//                    )
//                } ?? []
//
//                DispatchQueue.main.async {
//                    completion(journals)
//                }
//        }
//    }
    
    func fetchJournals(userID: String, completion: @escaping ([Journal]) -> Void) {
        
        db.collection("journals")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Error fetching journals: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let journals = snapshot?.documents.compactMap { document -> Journal? in
                    let data = document.data()
                    guard let title = data["title"] as? String else { return nil }

                    return Journal(
                        id: document.documentID,
                        userID: userID,
                        title: title
                    )
                } ?? []

                DispatchQueue.main.async {
                    completion(journals)
                }
            }
    }

    // Fetches ALL entries from all journals and sorts them by date (Most recent first)
    func fetchAllEntries(userID: String, completion: @escaping ([Entry]) -> Void) {
        db.collection("entries")
            .whereField("userID", isEqualTo: userID)
            .order(by: "date", descending: false) // Sort by date (newest first)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching all entries: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let entries = snapshot?.documents.compactMap { doc -> Entry? in
                    let data = doc.data()
                    return Entry(
                        id: doc.documentID,
                        journalID: data["journalID"] as? String ?? "",
                        userID: data["userID"] as? String ?? "",
                        title: data["title"] as? String ?? "Untitled",
                        content: data["content"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        moods: data["moods"] as? [String] ?? [],
                        mediaFiles: data["media"] as? [String] ?? []
                    )
                } ?? []

                DispatchQueue.main.async {
                    print("✅ Fetched \(entries.count) entries for user \(userID) @fetchAllEntries in FirebaseService.swift.")
                    completion(entries)
                }
            }
    }
    
    // Fetch All Entries from a specific Journal
    func fetchEntriesFromJournal(journalID: String, completion: @escaping ([Entry]) -> Void) {
        let lowercasedJournalID = journalID.lowercased()
        
        print("🔍 Firestore Query: Fetching entries where journalID == \(lowercasedJournalID)") // ✅ Debugging Log
        
        db.collection("entries")
            .whereField("journalID", isEqualTo: lowercasedJournalID)
            .order(by: "date", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching entries: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let entries = snapshot?.documents.compactMap { document -> Entry? in
                    let data = document.data()
                    guard let userID = data["userID"] as? String,
                          let title = data["title"] as? String,
                          let content = data["content"] as? String,
                          let timestamp = data["date"] as? Timestamp else {
                        return nil
                    }

                    let date = timestamp.dateValue() // Convert Firestore Timestamp to Date
                    let moods = data["moods"] as? [String] ?? []
                    let media = data["media"] as? [String] ?? []

                    return Entry(
                        id: document.documentID,
                        journalID: journalID,
                        userID: userID,
                        title: title,
                        content: content,
                        date: date,
                        moods: moods,
                        mediaFiles: media
                    )
                } ?? []

                DispatchQueue.main.async {
                    print("✅ Entries fetched for \(lowercasedJournalID): \(entries.count) at fetchEntriesFromJournal in FirebaseService.swift")
                    completion(entries)
                }
            }
    }
    
    func fetchImageURL(imagePath: String, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference(withPath: imagePath)
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print("❌ Error getting download URL: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let url = url {
                print("✅ Image Download URL: \(url.absoluteString)")
                completion(url.absoluteString)
            }
        }
    }
    
    // Save a new Journal
    func saveJournal(userID: String, title: String, completion: @escaping (Bool) -> Void) {
        let newJournal: [String: Any] = [
            "userID": userID,
            "title": title,
            "createdAt": Date().timeIntervalSince1970,
            "entries": []
        ]

        db.collection("journals").addDocument(data: newJournal) { error in
            if let error = error {
                print("❌ Failed to save journal: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Journal saved successfully!")
                completion(true)
            }
        }
    }

    // Save an entry inside a specific journal
    func saveEntry(journalID: String, userID: String, title: String, content: String, moods: [String], completion: @escaping (Bool) -> Void) {
        let newEntry: [String: Any] = [
            "journalID": journalID,
            "userID": userID,
            "title": title,
            "content": content,
            "moods": moods,
            "date": Date().timeIntervalSince1970
        ]

        db.collection("entries").addDocument(data: newEntry) { error in
            if let error = error {
                print("❌ Failed to save entry: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Entry saved successfully!")
                completion(true)
            }
        }
    }
}
