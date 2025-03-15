//
//  TopNavBarView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

import SwiftUI

struct TopNavBarView: View {
    @Binding var isSidebarOpen: Bool
    @Binding var selectedJournal: String
    let journals: [Journal]
    let onCreateEntry: () -> Void
    let onSearch: () -> Void

    var body: some View {
            HStack {
                // Hamburger Menu Button
                Button(action: { isSidebarOpen.toggle() }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                        .foregroundColor(.purple)
                }

                Spacer()

                // Journal Dropdown
                Menu {
                    ForEach(journals, id: \.id) { journal in
                        Button(action: {
                            selectedJournal = journal.title
                        }) {
                            Text(journal.title)
                        }
                    }
                } label: {
                    Text(selectedJournal)
                        .font(.headline)
                        .foregroundColor(.purple)
                }

                Spacer()

                // search and Add Entry Buttons
                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.purple)
                }

                Button(action: onCreateEntry) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .background(Color.white)
        }
}


struct TopNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopNavBarView(
            isSidebarOpen: .constant(false),
            selectedJournal: .constant("Personal"),
            journals: [
                Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date()),
                Journal(id: "2", userID: "user1", title: "Work", createdAt: Date())
            ], // Sample list of journals
            onCreateEntry: {}, // Empty closure for creating entries
            onSearch: {} // Empty closure for search
        )
    }
}

