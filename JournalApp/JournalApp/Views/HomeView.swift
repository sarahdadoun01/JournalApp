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
    @EnvironmentObject var appState: AppState

    @State private var isSidebarOpen = false
    @State private var selectedJournal = "All" // default to all
    @State private var selectedTag: String? = nil
    @State private var journals: [Journal] = []
    @State private var tags: [Tag]
    @State private var journalEntryCounts: [String: Int] = [:]
    @State private var tagEntryCounts: [String: Int] = [:]
    @State private var pinnedCount: Int = 0
    @State private var favoritesCount: Int = 0
    @State private var deletedCount: Int = 0
    @State private var allCount: Int = 0
    @State private var showAddJournalView = false
    @State private var showAddTagSheet = false

    @StateObject private var firebaseService = FirebaseService()

    init(tags: [Tag] = []) {
        _tags = State(initialValue: tags)
    }
    
    private func refreshTags() {
        Task {
            do {
                let fetchedTags = try await FirebaseService.shared.fetchUserTags()
                DispatchQueue.main.async {
                    self.tags = fetchedTags
                }
            } catch {
                print("❌ Failed to refresh tags: \(error.localizedDescription)")
            }
        }
    }


    var body: some View {
        NavigationStack{
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
                        journals: $journals,
                        selectedTag: $selectedTag,
                        onSearch: { print("Search...") },
                        tags: tags
                    )

                    // Show Entries for Selected Journal
                    EntryListView(journalID: selectedJournal, journals: $journals)
                    
                }

                // Sidebar Menu with Journal Selection
                SideBarView(
                    isShowing: $isSidebarOpen,
                    selectedJournal: $selectedJournal,
                    selectedTag: $selectedTag,
                    journals: $journals,
                    tags: $tags,
                    onSelectJournal: { journalID in
                        selectedJournal = journalID // Update journal when selected
                    },
                    onSelectTag: { tagName in
                        selectedTag = tagName
                        selectedJournal = "All" // optionally switch to All view
                    },
                    onLogout: {
                        do {
                            try FirebaseService.shared.signOut()
                            appState.isLoggedIn = false
                            appState.logout()
                        } catch {
                            print("❌ Logout failed: \(error.localizedDescription)")
                        }
                    },
                    onAddJournal: {
                        showAddJournalView = true
                    },
                    onAddTag: {
                        showAddTagSheet = true
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
                fetchJournalsForCurrentUser()
                refreshTags()
                
            }.navigationBarBackButtonHidden(true)
                .onChange(of: appState.isLoggedIn) { newValue in
                    if newValue {
                    fetchJournalsForCurrentUser()
                }
            }
            .sheet(isPresented: $showAddJournalView) {
                if let user = Auth.auth().currentUser {
                    AddJournalView(userID: user.uid) {
                        fetchJournalsForCurrentUser()
                        refreshTags()
                    }
                }
            }
            .sheet(isPresented: $showAddTagSheet) {
                if let user = Auth.auth().currentUser {
                    AddTagView(userID: user.uid) {
                        Task {
                            do {
                                tags = try await FirebaseService.shared.fetchUserTags()
                                refreshTags() // ✅ this line will reload the sidebar tags
                            } catch {
                                print("❌ Failed to reload tags after adding: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }


    }
    
    private func fetchJournalsForCurrentUser() {
        guard let user = Auth.auth().currentUser else {
            print("❌ No Firebase user — should NOT be in HomeView")
            return
        }

        let userID = user.uid

        firebaseService.fetchJournals(userID: userID) { fetchedJournals in
            DispatchQueue.main.async {
                let previousSelection = self.selectedJournal
                self.journals = fetchedJournals

                if fetchedJournals.contains(where: { $0.id == previousSelection }) {
                    self.selectedJournal = previousSelection
                } else {
                    self.selectedJournal = "All"
                }
            }

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
            .environmentObject(AppState())
    }
}
