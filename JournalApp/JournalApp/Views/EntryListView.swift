//
//  EntryListView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-27.
//

import SwiftUI
import FirebaseAuth

struct EntryListView: View {
    var journalID: String
    @State private var entries: [Entry] = []
    @StateObject private var firebaseService = FirebaseService()
    
    var body: some View {
        ScrollView {
            VStack {
                if entries.isEmpty {
                    Text("No entry yet.\nCreate an entry with the + icon")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(entries, id: \.id) { entry in
                        EntryListBlockView(entry: entry)
                    }
                }
            }
            .padding()
        }
        
        
        .onAppear {
            print("🟢 onAppear triggered for journal: \(journalID)") // ✅ Debugging Log
        }
        .onChange(of: journalID) { newJournalID in
            print("🔄 Journal changed to: \(newJournalID), fetching new entries...") // ✅ Debugging Log

            if newJournalID == "All" {
                if let user = Auth.auth().currentUser {
                    firebaseService.fetchAllEntries(userID: user.email ?? "testuser@example.com") { fetchedEntries in
                        print("✅ All Entries fetched: \(fetchedEntries.count)")
                        self.entries = fetchedEntries
                    }
                }
            } else {
                firebaseService.fetchEntriesFromJournal(journalID: newJournalID) { fetchedEntries in
                    print("✅ Entries fetched for \(newJournalID): \(fetchedEntries.count)")
                    self.entries = fetchedEntries
                }
            }
        }

        
        
        //DEBUGING
//        .onAppear {
//            print("🟢 onAppear triggered for journal: \(journalID)")
//
//            if journalID == "All" {
//                // Fetch ALL entries from all journals if "All" is selected
//                if let user = Auth.auth().currentUser {
//                    let userID = user.email ?? "testuser@example.com"
//                    print("🔍 Fetching ALL entries for user: \(userID)")
//
//                    firebaseService.fetchAllEntries(userID: userID) { fetchedEntries in
//                        print("✅ Fetched \(fetchedEntries.count) entries for 'All'")
//                        self.entries = fetchedEntries
//                    }
//                } else {
//                    print("❌ No user logged in")
//                }
//            } else {
//                // Fetch entries for a specific journal
//                print("🔍 Fetching entries for specific journal: \(journalID)")
//
//                firebaseService.fetchEntriesFromJournal(journalID: journalID) { fetchedEntries in
//                    print("✅ Fetched \(fetchedEntries.count) entries for journal: \(journalID)")
//                    self.entries = fetchedEntries
//                }
//            }
//        }
        
        
        
        
        
        // THIS IS WHAT I HAD BEFORE DEBUGGING.
//        .onAppear {
//
//            if journalID == "All" {
//                // Fetch ALL entries from all journals if "All" is selected
//                if let user = Auth.auth().currentUser {
//                    firebaseService.fetchAllEntries(userID: user.email ?? "testuser@example.com") {
//                        fetchedEntries in
//                        self.entries = fetchedEntries
//                    }
//                } else {
//                    print("❌ No user logged in")
//                }
//            } else {
//                // Fetch entries for the specific journal
//                firebaseService.fetchEntriesFromJournal(journalID: journalID) { fetchedEntries in
//                    self.entries = fetchedEntries
//                }
//            }
//        }
    }
}

struct EntryListView_Previews: PreviewProvider {
    static var previews: some View {
        EntryListView(journalID: "work") //  Pass a sample journal ID
    }
}
