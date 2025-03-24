//
//  HomeView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HomeView: View {
    @State private var isSidebarOpen = false
    @State private var selectedJournal = "All" // default to 'all'
    @State private var journals: [Journal] = []
    @State private var tags: [String] = ["Work", "Personal", "Ideas"]
    @State private var journalEntryCounts: [String: Int] = [:]
    @State private var tagEntryCounts: [String: Int] = [:]
    @State private var pinnedCount: Int = 0
    @State private var favoritesCount: Int = 0
    @State private var deletedCount: Int = 0
    @State private var allCount: Int = 0

    @StateObject private var firebaseService = FirebaseService()

    var body: some View {
        ZStack {
            VStack {
                // Top Navigation Bar
                TopNavBarView(
                    onSaveComplete: {
                        let current = selectedJournal
                        selectedJournal = "temp"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            selectedJournal = current
                        }
                    },
                    isSidebarOpen: $isSidebarOpen,
                    selectedJournal: $selectedJournal,
                    journals: journals,
                    onSearch: { print("Search...") }
                )

                // Show Entries for Selected Journal
                EntryListView(journalID: selectedJournal)
            }

            // Sidebar Menu with Journal Selection
            SideBarView(
                isShowing: $isSidebarOpen,
                selectedJournal: $selectedJournal,
                journals: journals,
                tags: tags,
                onSelectJournal: { journalID in
                    selectedJournal = journalID // Update journal when selected
                },
                journalEntryCounts: journalEntryCounts,
                tagEntryCounts: tagEntryCounts,
                pinnedCount: pinnedCount,
                favoritesCount: favoritesCount,
                deletedCount: deletedCount,
                allCount: allCount
            )
        }
        .onAppear {
            authenticateTestUser()
        }
    }
    
    private func authenticateTestUser() {
            if Auth.auth().currentUser == nil {

                Auth.auth().signIn(withEmail: "testuser@example.com", password: "123456") { result, error in
                    if let error = error {
                        print("❌ Firebase Auth failed: \(error.localizedDescription)")
                    } else {
                        fetchJournalsForCurrentUser()
                    }
                }
            } else {
                fetchJournalsForCurrentUser()
            }
        }
    
    private func fetchJournalsForCurrentUser() {
        if let user = Auth.auth().currentUser {
            let userID = user.email ?? "testuser@example.com"
            

            firebaseService.fetchJournals(userID: userID) { fetchedJournals in
                DispatchQueue.main.async {
                    // If selectedJournal is "All", keep it. Otherwise, preserve last selection.
                    let previousSelection = self.selectedJournal

                    self.journals = fetchedJournals

                    if fetchedJournals.contains(where: { $0.title == previousSelection }) {
                        self.selectedJournal = previousSelection
                    } else {
                        self.selectedJournal = "All"
                    }
                }
                
                
                // Fetch entries and compute counts
                firebaseService.fetchAllEntries(userID: userID) { entries in
                    print("✅ Fetched \(entries.count) entries")
                    
                    let counts = computeSidebarCounts(from: entries)

                    DispatchQueue.main.async {
                        self.journalEntryCounts = counts.journalCounts
                        self.tagEntryCounts = counts.tagCounts
                        self.pinnedCount = counts.pinned
                        self.favoritesCount = counts.favorites
                        self.deletedCount = counts.deleted
                        self.allCount = counts.all
                    }
                }
                
            }
        } else {
            print("❌ No user is logged in")
        }
    }
    
    
    private func fetchEntryCounts(for userID: String) {
        firebaseService.fetchAllEntries(userID: userID) { entries in
            var counts: [String: Int] = [:]

            for entry in entries {
                counts[entry.journalID, default: 0] += 1
            }

            counts["All"] = entries.count // total count for "All"

            DispatchQueue.main.async {
                self.journalEntryCounts = counts
            }
        }
    }

    

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
