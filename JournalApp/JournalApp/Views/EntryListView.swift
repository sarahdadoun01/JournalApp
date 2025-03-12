//
//  EntryListView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-27.
//

import SwiftUI

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
            firebaseService.fetchEntriesForJournal(journalID: journalID) { fetchedEntries in
                self.entries = fetchedEntries
            }
        }
    }
}


struct EntryListView_Previews: PreviewProvider {
    static var previews: some View {
        EntryListView(journalID: "sampleJournalID") //  Pass a sample journal ID
    }
}
