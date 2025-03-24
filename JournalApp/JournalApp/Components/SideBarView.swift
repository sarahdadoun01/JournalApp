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
    let journals: [Journal]
    let tags: [String]
    let onSelectJournal: (String) -> Void

    var body: some View {
            ZStack {
                if isShowing {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { isShowing = false }

                    HStack(spacing: 0) {
                        List {
                            // All Entries
                            Section {
                                SideBarItem(title: "All", iconName: "book.closed", count: 9, isSelected: selectedJournal == "All") {
                                    onSelectJournal("All")
                                    isShowing = false
                                }
                            }.padding(.horizontal, -16)
                            .padding(.vertical, -11)

                            // Journals
                            Section(header: Text("JOURNALS")) {
                                ForEach(journals, id: \.id) { journal in
                                    SideBarItem(title: journal.title, iconName: "book.fill", count: 6, isSelected: selectedJournal == journal.title) {
                                        onSelectJournal(journal.title)
                                        isShowing = false
                                    }
                                }

                                AddItemButton(title: "Add New Journal") {
                                    // Add new journal logic
                                }
                            }.padding(.horizontal, -16)
                                .padding(.vertical, -11)

                            // Tags
                            Section(header: Text("TAGS")) {
                                ForEach(tags, id: \.self) { tag in
                                    SideBarItem(title: tag, iconName: "tag.fill", count: 2, isSelected: false) {
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
                                SideBarItem(title: "Pinned", iconName: "pin.fill", count: 2, isSelected: false, action: {})
                                SideBarItem(title: "Favorites", iconName: "star.fill", count: 2, isSelected: false, action: {})
                                SideBarItem(title: "Deleted", iconName: "trash.fill", count: 3, isSelected: false, action: {})
                            }.padding(.horizontal, -16)
                                .padding(.vertical, -11)

                            // Settings
                            Section {
                                SideBarItem(title: "Settings", iconName: "gearshape.fill", count: nil, isSelected: false) {
                                    // Settings action
                                }
                            }.padding(.horizontal, -16)
                                .padding(.vertical, -11)
                            
                            
                        }.padding(.top, 50)
                        .padding(.bottom, 20)
                        .listStyle(InsetGroupedListStyle())
                        .frame(width: UIScreen.main.bounds.width * 0.75)
                        .background(Color(.systemGray6))
                        .edgesIgnoringSafeArea(.all)

                        Spacer()
                    }
                }
            }
            .animation(.easeInOut, value: isShowing)
        }
}

struct SectionLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.gray)
            .padding(.top, 10)
    }
}

struct AddItemButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle")
                Text(title)
            }
            .foregroundColor(.purple)
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
        }
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView(
            isShowing: .constant(true),
            selectedJournal: .constant("All"),
            journals: [
                Journal(id: "1", userID: "user1", title: "Journal1", createdAt: Date()),
                Journal(id: "2", userID: "user1", title: "Journal2", createdAt: Date())
            ],
            tags: ["Tag1", "Tag2"],
            onSelectJournal: { _ in }
        )
    }
}
