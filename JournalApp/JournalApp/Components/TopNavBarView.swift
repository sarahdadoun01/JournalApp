//
//  TopNavBarView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

import SwiftUI

struct TopNavBarView: View {
    let onSaveComplete: () -> Void
    
    @Binding var isSidebarOpen: Bool
    @Binding var selectedJournal: String
    
    @State private var isAddingEntry = false
    
    let journals: [Journal]
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
                    // Add the "All" option manually
                    Button(action: {
                        selectedJournal = "All"
                    }) {
                        Text("All")
                    }
                    
                    ForEach(journals, id: \.id) { journal in
                        Button(action: {
                            selectedJournal = journal.id
                        }) {
                            Text(journal.title)
                        }
                    }
                } label: {
                    Text(journals.first(where: { $0.id == selectedJournal })?.title ?? "All")
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

                Button(action: {
                    isAddingEntry = true // Opens AddEntryView
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .background(Color.white)
            .sheet(isPresented: $isAddingEntry) {
                AddEntryView(
                    onSaveComplete: {
                        onSaveComplete() // ✅ Refresh journal list in HomeView
                        isAddingEntry = false
                    },
                    selectedJournalID: selectedJournal
                )
                .transition(.move(edge: .bottom))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }

        }
}


struct TopNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopNavBarView(
            onSaveComplete: {},
            isSidebarOpen: .constant(false),
            selectedJournal: .constant("Personal"),
            journals: [
                Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date()),
                Journal(id: "2", userID: "user1", title: "Work", createdAt: Date())
            ], // Sample list of journals
            onSearch: {} // Empty closure for search
        )
    }
}

