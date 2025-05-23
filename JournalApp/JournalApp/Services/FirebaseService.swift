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

    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
    
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
    
    
    func createUserAccount(
        firstName: String,
        lastName: String,
        birthday: Date,
        email: String,
        password: String,
        passcode: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No UID returned."])))
                return
            }

            let salt = generateRandomSalt()
            let hashed = hashPasscode(passcode, salt: salt)

            let userData: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "birthday": Timestamp(date: birthday),
                "email": email.lowercased(),
                "passcodeSalt": salt,
                "passcodeHashed": hashed
            ]

            Firestore.firestore().collection("users").document(uid).setData(userData) { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    completion(.success(uid))
                }
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
    
    func verifyPasscodeForUser(uid: String, typedPasscode: String, completion: @escaping (Bool) -> Void) {
        print("🔍 Verifying passcode for UID: \(uid)")

        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user doc: \(error.localizedDescription)")
                completion(false)
                return
            }

            // Check if document exists
            guard let data = snapshot?.data() else {
                print("❌ No data found for UID \(uid)")
                completion(false)
                return
            }

            print("📦 Document data: \(data)")

            guard let salt = data["passcodeSalt"] as? String else {
                print("❌ Missing 'passcodeSalt' field")
                completion(false)
                return
            }

            guard let storedHash = data["passcodeHashed"] as? String else {
                print("❌ Missing 'passcodeHashed' field")
                completion(false)
                return
            }

            let typedHash = hashPasscode(typedPasscode, salt: salt)

            print("🔐 Typed hash: \(typedHash)")
            print("🗃 Stored hash: \(storedHash)")

            let isMatch = typedHash == storedHash
            print(isMatch ? "✅ Passcode match!" : "❌ Passcode mismatch.")

            completion(isMatch)
        }
    }
    
    func storePasscodeForUser(uid: String, passcode: String) {
        let salt = generateRandomSalt()
        let hashed = hashPasscode(passcode, salt: salt)

        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.setData([
            "passcodeSalt": salt,
            "passcodeHashed": hashed
        ], merge: true) { error in
            if let error = error {
                print("❌ Error saving passcode: \(error.localizedDescription)")
            } else {
                print("✅ Passcode stored successfully!")
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
                    let colorHex = data["colorHex"] as? String ?? "#007BFF"

                    return Journal(
                        id: document.documentID,
                        userID: userID,
                        title: title,
                        colorHex: colorHex
                    )
                } ?? []

                DispatchQueue.main.async {
                    print("📘 Journals fetched:")
                    journals.forEach { j in
                        print("- \(j.title) | colorHex: \(j.colorHex)")
                    }

                    completion(journals)
                }
            }
    }
    
    func createJournal(userID: String, title: String, colorHex: String, completion: @escaping (Bool) -> Void) {
        let journalData: [String: Any] = [
            "userID": userID,
            "title": title,
            "createdAt": Date().timeIntervalSince1970,
            "entries": [],
            "colorHex": colorHex
        ]

        db.collection("journals").addDocument(data: journalData) { error in
            if let error = error {
                print("❌ Failed to create journal: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Journal created!")
                completion(true)
            }
        }
    }
    
    func fetchUserTagsName() async throws -> [String] {
        guard let userID = Auth.auth().currentUser?.uid else {
            return []
        }

        let db = Firestore.firestore()
        let snapshot = try await db.collection("tags")
            .whereField("userID", isEqualTo: userID)
            .getDocuments()

        let tags = snapshot.documents.compactMap { $0["name"] as? String }
        return tags
    }
    
    func fetchUserTags() async throws -> [Tag] {
        guard let userID = Auth.auth().currentUser?.uid else {
            return []
        }

        let snapshot = try await db.collection("tags")
            .whereField("userID", isEqualTo: userID)
            .getDocuments()

        let tags = snapshot.documents.compactMap { doc -> Tag? in
            guard let name = doc["name"] as? String,
                  let colorHex = doc["colorHex"] as? String else {
                return nil
            }
            return Tag(id: doc.documentID, name: name, colorHex: colorHex)
        }

        return tags
    }
    
    func createTag(userID: String, name: String, colorHex: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "userID": userID,
            "name": name,
            "colorHex": colorHex
        ]

        db.collection("tags").addDocument(data: data) { error in
            completion(error == nil)
        }
    }


    // Fetches ALL entries from all journals and sorts them by date (Most recent first)
    func fetchAllEntries(userID: String, completion: @escaping ([Entry]) -> Void) {
        print("Fetching entries for userID: \(userID)")

        db.collection("entries")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching entries: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let docs = snapshot?.documents ?? []
                print("📦 Firestore returned \(docs.count) documents")

                let entries = docs.compactMap { doc -> Entry? in
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
                }

                DispatchQueue.main.async {
                    completion(entries.sorted { $0.date > $1.date })
                }
            }
    }

    
    // Fetch All Entries from a specific Journal
    func fetchEntriesFromJournal(journalID: String, userID: String, completion: @escaping ([Entry]) -> Void) {
        
        db.collection("entries")
            .whereField("journalID", isEqualTo: journalID)
            .whereField("userID", isEqualTo: userID)
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
    
    func fetchMediaFiles(for entryID: String) async throws -> [MediaFile] {
        let snapshot = try await Firestore.firestore()
            .collection("media")
            .whereField("entryID", isEqualTo: entryID)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard
                let fileURL = data["fileURL"] as? String,
                let fileTypeRaw = data["fileType"] as? String,
                let fileType = MediaType(rawValue: fileTypeRaw)
            else { return nil }

            return MediaFile(
                id: doc.documentID,
                entryID: entryID,
                fileURL: fileURL,
                fileType: fileType
            )
        }
    }

    
    func saveMediafiles(entryID: String, fileURL: String, fileType: MediaType, completion: @escaping (Bool) -> Void){
        let db = Firestore.firestore()
        let mediaCollection = db.collection("media")
        
        let newDoc = mediaCollection.document()
        
        let mediaData: [String: Any] = [
            "id": newDoc.documentID,
            "entryID": entryID,
            "fileURL": fileURL,
            "fileType": fileType.rawValue
        ]
        
        newDoc.setData(mediaData) { error in
            if let error = error {
                print("❌ Failed to save media file: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Media file saved with ID \(newDoc.documentID)")
                completion(true)
            }
        }
    }
    
    func deleteImage(at url: String) {
        let storageRef = Storage.storage().reference(forURL: url)
        storageRef.delete { error in
            if let error = error {
                print("❌ Failed to delete image: \(error.localizedDescription)")
            } else {
                print("🗑️ Deleted unused image: \(url)")
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

    @MainActor
    func uploadMedia(from localPath: String, type: BlockType) async -> String? {
        guard let fileURL = URL(string: localPath),
              let fileData = try? Data(contentsOf: fileURL) else {
            print("❌ Failed to load data from local path: \(localPath)")
            return nil
        }

        let folder = type == .audio ? "audio" : "videos"
        let ext = type == .audio ? "m4a" : "mp4"
        let fileName = UUID().uuidString + ".\(ext)"
        let storageRef = Storage.storage().reference().child("\(folder)/\(fileName)")

        do {
            let _ = try await storageRef.putDataAsync(fileData, metadata: nil)
            let downloadURL = try await storageRef.downloadURL()
            print("✅ Uploaded \(type) to:", downloadURL.absoluteString)
            return downloadURL.absoluteString
        } catch {
            print("❌ Error uploading \(type): \(error.localizedDescription)")
            return nil
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
