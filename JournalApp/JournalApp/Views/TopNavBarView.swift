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
            }

            Spacer()

            // Journal Dropdown
            Menu {
                ForEach(journals, id: \.id) { journal in
                    Button(action: { selectedJournal = journal.id }) {
                        Text(journal.title)
                    }
                }
            } label: {
                Text(selectedJournal.isEmpty ? "Select Journal" : selectedJournal)
                    .font(.headline)
            }

            Spacer()

            // Search and Add Buttons
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
            }

            Button(action: onCreateEntry) {
                Image(systemName: "plus")
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 2)
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

