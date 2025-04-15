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
    @State private var activeSwipedEntryID: String? = nil
    @State private var selectedEntry: Entry? = nil
    
    @Binding var journals: [Journal]
    
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
                        let entry = entries[index]
                        EntryListBlockView(
                            onTap: {
                                selectedEntry = entry
                            },
                            entry: entry,
                            activeSwipedID: $activeSwipedEntryID,
                            onDelete: {
                                deleteEntry(at: index)
                            }
                        )
                    }


                }
            }
            .padding()
            .sheet(item: $selectedEntry) { entry in
                AddEntryView(
                    journals: $journals,
                    entryTitle: entry.title,
                    selectedMoods: entry.moods ?? [],
                    selectedTags: entry.tags,
                    blocks: convertEntryToBlocks(entry),
                    selectedJournalID: entry.journalID,
                    entryID: entry.id
                )
            }
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
            let currentJournalID = journalID
            
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
                    withAnimation {
                        self.entries.removeAll { $0.id == entryToDelete.id }
                    }
                }
            }
        }
    }
    
    private func convertEntryToBlocks(_ entry: Entry) -> [EntryBlock] {
        var blocks: [EntryBlock] = []

        if !entry.content.isEmpty {
            blocks.append(EntryBlock(type: .text, content: entry.content))
        }

        for url in entry.mediaFiles ?? [] {
            if url.hasSuffix(".m4a") {
                blocks.append(EntryBlock(type: .audio, content: url))
            } else if url.hasSuffix(".mp4") {
                blocks.append(EntryBlock(type: .video, content: url))
            } else {
                blocks.append(EntryBlock(type: .image, content: url))
            }
        }

        return blocks
    }

}

struct EntryListView_Previews: PreviewProvider {
    @State static var journals: [Journal] = [
        Journal(id: "1", userID: "testuser@example.com", title: "Work", createdAt: Date()),
        Journal(id: "2", userID: "testuser@example.com", title: "Personal", createdAt: Date())
    ]
    
    static var previews: some View {
        EntryListView(
            journalID: "work",
            journals: $journals
        )
    }
}
