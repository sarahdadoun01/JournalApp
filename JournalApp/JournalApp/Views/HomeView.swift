//
//  HomeView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

import SwiftUI

struct HomeView: View {
    @State private var isSidebarOpen = false
    @State private var selectedJournal = "All"
    @State private var journals: [Journal] = []
    @State private var tags: [String] = ["Work", "Personal", "Ideas"]
    @StateObject private var firebaseService = FirebaseService()

    var body: some View {
        ZStack {
            VStack {
                // Pass selectedJournal Binding to update in real-time
                TopNavBarView(
                    isSidebarOpen: $isSidebarOpen,
                    selectedJournal: $selectedJournal,
                    journals: journals,
                    onCreateEntry: { print("Create Entry") },
                    onSearch: { print("Search...") }
                )

                // Show Entries for the Selected Journal
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
                }
            )
        }
        .onAppear {
            Auth.auth().signIn(withEmail: "testuser@example.com", password: "password123") { result, error in
                if let error = error {
                    print("❌ Firebase Auth failed: \(error.localizedDescription)")
                    return
                }
                print("✅ Signed in as test user!")

                let userID = result?.user.email ?? "testuser@example.com"
                firebaseService.fetchJournals(userID: userID) { fetchedJournals in
                    self.journals = [Journal(id: "All", userID: userID, title: "All")] + fetchedJournals
                }
            }
        }
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
