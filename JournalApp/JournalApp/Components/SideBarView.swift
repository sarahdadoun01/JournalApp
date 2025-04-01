//
//  SideBarView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

//
//  SideBarView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//
import Foundation
import SwiftUI

struct SideBarView: View {
    @Binding var isShowing: Bool
    @Binding var selectedJournal: String
    @Binding var journals: [Journal]
    let tags: [String]
    let onSelectJournal: (String) -> Void
    let onLogout: () -> Void
    let onAddJournal: () -> Void
    
    // Accept the counts
    let journalEntryCounts: [String: Int]
    let tagEntryCounts: [String: Int]
    let pinnedCount: Int
    let favoritesCount: Int
    let deletedCount: Int
    let allCount: Int


    var body: some View {
            ZStack {
                if isShowing {
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(BlurView(style: .systemUltraThinMaterial)) // this line adds blur
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { isShowing = false }


                    HStack(spacing: 0) {
                        List {
                            // All Entries
                            Section {
                                SideBarItem(title: "All", iconName: "book.closed", count: allCount, isSelected: selectedJournal == "All") {
                                    onSelectJournal("All")
                                    isShowing = false
                                }
                            }.padding(.horizontal, -16)
                            .padding(.vertical, -11)

                            // Journals
                            
                            Section(header: Text("JOURNALS")) {
                                ForEach(journals, id: \.id) { journal in
                                    SideBarItem(title: journal.title, iconName: "book.fill", count: journalEntryCounts[journal.id] ?? 0, isSelected: selectedJournal == journal.id) {
                                        onSelectJournal(journal.id)
                                        isShowing = false
                                    }
                                }

                                AddItemButton(title: "Add New Journal", action: onAddJournal)

                            }.padding(.horizontal, -16)
                                .padding(.vertical, -11)

                            // Tags
                            Section(header: Text("TAGS")) {
                                ForEach(tags, id: \.self) { tag in
                                    SideBarItem(title: tag, iconName: "tag.fill", count: tagEntryCounts[tag] ?? 0, isSelected: false) {
                                        // Tag tap logic
                                    }
                                }

                                AddItemButton(title: "Add New Tag") {
                                    // Add new tag logic
                                }
                            }.padding(.horizontal, -16)
                                .padding(.vertical, -11)

                            // Other
                            Section {
                                SideBarItem(title: "Pinned", iconName: "pin.fill", count: pinnedCount, isSelected: false, action: {})
                                SideBarItem(title: "Favorites", iconName: "star.fill", count: favoritesCount, isSelected: false, action: {})
                                SideBarItem(title: "Deleted", iconName: "trash.fill", count: deletedCount, isSelected: false, action: {})
                            }.padding(.horizontal, -16)
                                .padding(.vertical, -11)

                            // Settings
                            Section {
                                SideBarItem(title: "Settings", iconName: "gearshape.fill", count: nil, isSelected: false) {
                                    // Settings action
                                }
                                SideBarItem(title: "Logout", iconName: "arrow.backward.circle.fill", count: nil, isSelected: false) {
                                    onLogout()
                                    isShowing = false
                                }
                                
                            }.padding(.horizontal, -16)
                                .padding(.vertical, -11)
                            
                            
                        }.padding(.top, 50)
                        .padding(.bottom, 20)
                        .listStyle(InsetGroupedListStyle())
                        .frame(width: UIScreen.main.bounds.width * 0.75)
                        .background(Color(.systemGray6))
                        .edgesIgnoringSafeArea(.all)
                        .offset(x: isShowing ? 0 : -UIScreen.main.bounds.width)
                        .animation(.easeInOut(duration: 0.3), value: isShowing)

                        Spacer()
                    }
                }
            }
            .animation(.easeInOut, value: isShowing)
        }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView(
            isShowing: .constant(true),
            selectedJournal: .constant("All"),
            journals: .constant([
                Journal(id: "1", userID: "user1", title: "Journal1", createdAt: Date()),
                Journal(id: "2", userID: "user1", title: "Journal2", createdAt: Date())
            ]),
            tags: ["Tag1", "Tag2"],
            onSelectJournal: { _ in },
            onLogout: {},
            onAddJournal: {},
            journalEntryCounts: ["1": 4, "2": 3],
            tagEntryCounts: ["Tag1": 3, "Tag2": 1],
            pinnedCount: 2,
            favoritesCount: 3,
            deletedCount: 4,
            allCount: 5
        )
    }
}
