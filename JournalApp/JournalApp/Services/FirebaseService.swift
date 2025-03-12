//
//  FirebaseService.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-25.
//

import Foundation
import FirebaseFirestore

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
    
    // Fetch Entries from a journal
    func fetchEntriesForJournal(journalID: String, completion: @escaping ([Entry]) -> Void) {
        db.collection("entries")
            .whereField("journalID", isEqualTo: journalID)
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
                            let timestamp = data["createdAt"] as? Timestamp else {
                    return nil
                }
                        
                let createdAt = timestamp.dateValue() // Convert Firestore Timestamp to Date
                let moods = data["moods"] as? [String] ?? []
                    
                return Entry(
                    id: document.documentID,
                    journalID: journalID,
                    userID: userID,
                    title: title,
                    content: content,
                    date: createdAt,
                    moods: moods
                )
            } ?? []

            DispatchQueue.main.async {
                completion(entries)
            }
        }
    }
    
    // Fetches all journals for a given userID
    func fetchJournals(userID: String, completion: @escaping ([Journal]) -> Void) {
        db.collection("journals")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching journals: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let journals = snapshot?.documents.compactMap { doc -> Journal? in
                    let data = doc.data()
                    return Journal(
                        id: doc.documentID,
                        userID: data["userID"] as? String ?? "",
                        title: data["title"] as? String ?? "Untitled",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []
                completion(journals)
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
