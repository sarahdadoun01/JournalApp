//
//  HomeView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @State private var isSidebarOpen = false
    @State private var selectedJournal = "All"
    @State private var journals: [Journal] = []
    @State private var tags: [String] = ["Work", "Personal", "Ideas"] // Placeholder tags
    @StateObject private var firebaseService = FirebaseService()

    var body: some View {
        ZStack {
            VStack {
                // Top Navigation Bar
                TopNavBarView(
                    isSidebarOpen: $isSidebarOpen,
                    selectedJournal: $selectedJournal,
                    journals: journals,
                    onCreateEntry: { print("Create Entry") },
                    onSearch: { print("Search") }
                )

                // Entry List View
                EntryListView(journalID: selectedJournal)
            }

            // Sidebar Menu
            SideBarView(
                isShowing: $isSidebarOpen,
                selectedJournal: $selectedJournal,
                journals: journals,
                tags: tags,
                onSelectJournal: { journalID in
                    selectedJournal = journalID
                }
            )
        }
        .onAppear {
            // Fetch user's journals
            firebaseService.fetchJournals(userID: "test_user") { fetchedJournals in
                self.journals = fetchedJournals
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
