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
    @Binding var selectedTag: String?
    @Binding var journals: [Journal]
    @Binding var tags: [Tag]

    let onSelectJournal: (String) -> Void
    let onSelectTag: (String) -> Void
    let onLogout: () -> Void
    let onAddJournal: () -> Void
    let onAddTag: () -> Void

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
                        .background(BlurView(style: .systemUltraThinMaterial))
                        .ignoresSafeArea()
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
                                    SideBarItem(
                                        title: journal.title,
                                        iconName: "book.fill",
                                        count: journalEntryCounts[journal.id] ?? 0,
                                        isSelected: selectedJournal == journal.id,
                                        iconColor: Color(hex: journal.colorHex),
                                        action: {
                                            onSelectJournal(journal.id)
                                            isShowing = false
                                        }
                                    )
                                }

                                AddItemButton(title: "Add New Journal", action: onAddJournal)
                            }.padding(.horizontal, -16)
                            .padding(.vertical, -11)



                            // Tags
                            Section(header: Text("TAGS")) {
                                ForEach(tags) { tag in
                                    SideBarItem(
                                        title: tag.name,
                                        iconName: "tag.fill",
                                        count: tagEntryCounts[tag.id] ?? 0,
                                        isSelected: false,
                                        iconColor: Color(hex: tag.colorHex),
                                        action: {
                                            onSelectTag(tag.name)
                                            isShowing = false
                                        }
                                    )
                                }

                                AddItemButton(title: "Add New Tag", action: onAddTag)

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
            selectedJournal: .constant("1"),
            selectedTag: .constant("Tag1"),
            journals: .constant([
                Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date()),
                Journal(id: "2", userID: "user1", title: "Work", createdAt: Date())
            ]),
            tags: .constant([
                Tag(id: "Tag1", name: "Tag1", colorHex: "#FF5733"),
                Tag(id: "Tag2", name: "Tag2", colorHex: "#33B5FF")
            ]),
            onSelectJournal: { id in print("📘 Selected Journal: \(id)") },
            onSelectTag: { name in print("🏷️ Selected Tag: \(name)") },
            onLogout: { print("🚪 Logged out") },
            onAddJournal: { print("➕ Add New Journal") },
            onAddTag: { print("➕ Add New Tag") },
            journalEntryCounts: ["1": 5, "2": 3],
            tagEntryCounts: ["Tag1": 2, "Tag2": 4],
            pinnedCount: 2,
            favoritesCount: 3,
            deletedCount: 1,
            allCount: 10
        )
        .environmentObject(AppState())
        .previewLayout(.sizeThatFits)
    }
}
