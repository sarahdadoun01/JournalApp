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
                    ForEach(entries.indices, id: \.self) { index in
                        EntryListBlockView(entry: entries[index]) {
                            deleteEntry(at: index)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            
            if journalID == "All" {
                
                if let user = Auth.auth().currentUser {
                    firebaseService.fetchAllEntries(userID: user.uid) { fetchedEntries in
                        self.entries = fetchedEntries
                    }
                }
                
            } else {
                
                if let user = Auth.auth().currentUser {
                    firebaseService.fetchEntriesFromJournal(journalID: journalID, userID: user.uid) { fetchedEntries in
                        self.entries = fetchedEntries
                    }
                }
                
            }
        }
        .task(id: journalID) {
            let currentJournalID = journalID // snapshot the value
            
            if currentJournalID == "All" {
                
                if let user = Auth.auth().currentUser {
                    firebaseService.fetchAllEntries(userID: user.uid) { fetchedEntries in
                        DispatchQueue.main.async {
                            self.entries = fetchedEntries
                        }
                    }
                }
                
            } else {
                
                if let user = Auth.auth().currentUser {
                    firebaseService.fetchEntriesFromJournal(journalID: currentJournalID, userID: user.uid) { fetchedEntries in
                        DispatchQueue.main.async {
                            self.entries = fetchedEntries
                        }
                    }
                }
            }
        }


        
    }

    
    private func deleteEntry(at index: Int) {
        let entryToDelete = entries[index]
        
        firebaseService.deleteEntry(entryID: entryToDelete.id) { success in
            if success {
                DispatchQueue.main.async {
                    entries.remove(at:index)
                }
            }
            
        }
    }
}

struct EntryListView_Previews: PreviewProvider {
    static var previews: some View {
        EntryListView(journalID: "work")
    }
}
