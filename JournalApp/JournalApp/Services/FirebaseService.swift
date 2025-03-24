//
//  FirebaseService.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth


@MainActor
class FirebaseService: ObservableObject {
    @Published var journalEntries: [Entry] = []
    
    private let db = Firestore.firestore()
    let storage = Storage.storage()
    static let shared = FirebaseService()
    
    
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
    
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func logIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    
    // Listener that updated UI for new/edited entries.
    func observeJournalEntries() {
            db.collection("entries").addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("❌ Error fetching journal entries: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                DispatchQueue.main.async {
                    self.journalEntries = documents.compactMap { doc in
                        var data = doc.data()
                        data["id"] = doc.documentID // Ensure ID is included
                        return Entry.fromFirestore(document: data)
                }
            }
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
        
        print("Fetching for userID:", userID)

        
//        db.collection("entries")
//            .whereField("userID", isEqualTo: userID)
//            .order(by: "date", descending: false) // Sort by date (newest first)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ Error fetching all entries: \(error.localizedDescription)")
//                    completion([])
//                    return
//                }
//
//                let docs = snapshot?.documents ?? []
//                print("📦 Firestore returned \(docs.count) documents")
//
//                var entries = snapshot?.documents.compactMap { doc -> Entry? in
//                    let data = doc.data()
//
//                    print("Found entry with userID:", data["userID"] ?? "none")
//
//                    return Entry(
//                        id: doc.documentID,
//                        journalID: data["journalID"] as? String ?? "",
//                        userID: data["userID"] as? String ?? "",
//                        title: data["title"] as? String ?? "Untitled",
//                        content: data["content"] as? String ?? "",
//                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
//                        moods: data["moods"] as? [String] ?? [],
//                        mediaFiles: data["mediaFiles"] as? [String] ?? [],
//                        tags: data["tags"] as? [String] ?? []
//                    )
//                } ?? []
//
//                DispatchQueue.main.async {
//
//                    entries.sort { $0.date > $1.date  }
//
//                    // debug
//                    for entry in entries {
//                        print("Title: \(entry.title), Date: \(entry.date)")
//                    }
//
//                    completion(entries)
//                }
//            }
        
        db.collection("entries")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching all entries: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let docs = snapshot?.documents ?? []
                print("📦 Firestore returned \(docs.count) documents")

                var entries = snapshot?.documents.compactMap { doc -> Entry? in
                    let data = doc.data()
                    
                    print("Found entry with userID:", data["userID"] ?? "none")

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
                    
                    entries.sort { $0.date > $1.date }
                    completion(entries)
                }
            }
        
    }
    
    // Fetch All Entries from a specific Journal
    func fetchEntriesFromJournal(journalID: String, completion: @escaping ([Entry]) -> Void) {
        
        db.collection("entries")
            .whereField("journalID", isEqualTo: journalID)
            .order(by: "date", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching entries: \(error.localizedDescription)")
                    completion([])
                    return
                }

                var entries = snapshot?.documents.compactMap { document -> Entry? in
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
                    
                    entries.sort { $0.date > $1.date  }
                    
                    // debug
                    for entry in entries {
                        print("Title: \(entry.title), Date: \(entry.date)")
                    }
                    
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
            "date": Timestamp(date: Date())
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
    
    func deleteEntry(entryID: String, completion: @escaping (Bool) -> Void)  {
        
        db.collection("entries").document(entryID).delete { error in
            if let error = error {
                print("❌ Failed to delete entry: \(error.localizedDescription)")
                completion(false)
            } else {
                print ("Entry deleted successfully")
                completion(true)
            }
            
        }
    }
}
