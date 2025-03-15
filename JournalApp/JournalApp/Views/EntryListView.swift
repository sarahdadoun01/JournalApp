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
            .padding(.horizontal)
        }
        
        
        .onAppear {
            print("🟢 onAppear triggered for journal: \(journalID)") // ✅ Debugging Log
            
            if let user = Auth.auth().currentUser {
                firebaseService.fetchAllEntries(userID: user.email ?? "testuser@example.com") { fetchedEntries in
                    self.entries = fetchedEntries
                }
            }
        }
        .onChange(of: journalID) { newJournalID in
            
            

            if newJournalID == "All" {
                if let user = Auth.auth().currentUser {
                    firebaseService.fetchAllEntries(userID: user.email ?? "testuser@example.com") { fetchedEntries in
                        self.entries = fetchedEntries
                    }
                }
            } else {
                firebaseService.fetchEntriesFromJournal(journalID: newJournalID) { fetchedEntries in
                    self.entries = fetchedEntries
                }
            }
        }
    }
}

struct EntryListView_Previews: PreviewProvider {
    static var previews: some View {
        EntryListView(journalID: "work") //  Pass a sample journal ID
    }
}
