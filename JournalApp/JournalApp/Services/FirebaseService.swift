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
    let storage = Storage.storage()
    
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
                        mediaFiles: data["mediaFiles"] as? [String] ?? [],
                        tags: data["tags"] as? [String] ?? []
                    )
                } ?? []

                DispatchQueue.main.async {
                    completion(entries)
                }
            }
    }
    
    // Fetch All Entries from a specific Journal
    func fetchEntriesFromJournal(journalID: String, completion: @escaping ([Entry]) -> Void) {
        let lowercasedJournalID = journalID.lowercased()
        
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
                    let media = data["mediaFiles"] as? [String] ?? []
                    let tags = data["tags"] as? [String] ?? []

                    return Entry(
                        id: document.documentID,
                        journalID: journalID,
                        userID: userID,
                        title: title,
                        content: content,
                        date: date,
                        moods: moods,
                        mediaFiles: media,
                        tags: tags
                    )
                } ?? []

                DispatchQueue.main.async {
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
                completion(url.absoluteString)
            }
        }
    }
    
    // Upload media to Firebase Storage when Entry is saved
    @MainActor
    func uploadImage(image: UIImage) async -> String? {
        let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }

        do {
            let _ = try await storageRef.putDataAsync(imageData, metadata: nil)
            let downloadURL = try await storageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            print("❌ Error uploading image: \(error.localizedDescription)")
            return nil
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
                print("Journal saved successfully!")
                completion(true)
            }
        }
    }

    // Save an entry inside a specific journal
    func saveEntry(journalID: String, userID: String, title: String, content: String, moods: [String]?, mediaFiles: [String]?, tags: [String]?, completion: @escaping (Bool) -> Void) {
        var newEntry: [String: Any] = [
            "journalID": journalID,
            "userID": userID,
            "title": title,
            "content": content,
            "moods": moods ?? [],
            "tags": tags ?? [],
            "date": Date().timeIntervalSince1970
        ]
        
        // Ensure tags is saved
        if let tags = tags {
            newEntry["tags"] = tags
        } else {
            newEntry["tags"] = [] // Ensure Firestore gets an empty array instead of nil
        }
        
        // Ensure media files are saved if not empty
        if let mediaFiles = mediaFiles, !mediaFiles.isEmpty {
            newEntry["mediaFiles"] = mediaFiles
        }

        db.collection("entries").addDocument(data: newEntry) { error in
            if let error = error {
                print("❌ Failed to save entry: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Entry saved successfully!")
                completion(true)
            }
        }
    }
}
