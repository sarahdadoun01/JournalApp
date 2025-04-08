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
    @Binding var journals: [Journal]
    @Binding var selectedTag: String?
    @State private var isAddingEntry = false
    
    let onSearch: () -> Void
    let tags: [Tag]


    var body: some View {
            HStack {
                CircularIconButtonView(
                    systemName: "line.horizontal.3",
                    size: 45,
                    padding: 14,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D6D6D6"),
                    iconColor: .black
                ) {
                    isSidebarOpen.toggle()
                }

                Spacer()

                // Journal Dropdown
                Menu {
                    // All Option
                    Button(action: {
                        selectedJournal = "All"
                    }) {
                        Text("All")
                    }
                    
                    // List Journals
                    ForEach(journals, id: \.id) { journal in
                        Button(action: {
                            selectedJournal = journal.id
                        }) {
                            Text(journal.title)
                        }
                    }
                    
                    Divider()
                    
                    // List Tags
                    ForEach(tags, id: \.id) { tag in
                        Button(action: {
                            selectedTag = tag.name
                            selectedJournal = "All" // or "" depending on how you want to deselect journals
                        }) {
                            Label("#\(tag.name)", systemImage: selectedTag == tag.name ? "checkmark" : "")
                        }
                    }
                    
                } label: {
                    HStack(spacing: 8) {
                            Text(journals.first(where: { $0.id == selectedJournal })?.title ?? "All")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.black)
                        .foregroundColor(Color(hex: "#1A1F3B"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(.black, lineWidth: 1)
                        )
                        .cornerRadius(999)
                }

                Spacer()

                CircularIconButtonView(
                    systemName: "magnifyingglass",
                    size: 45,
                    padding: 15,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D6D6D6"),
                    iconColor: .black
                ) {
                    print("Plus tapped")
                }
                
                CircularIconButtonView(
                    systemName: "plus",
                    size: 45,
                    padding: 15,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D6D6D6"),
                    iconColor: .black
                ) {
                    isAddingEntry = true
                }
            }
            .padding()
            .background(Color.white)
            .sheet(isPresented: $isAddingEntry) {
                AddEntryView(
                    journals: $journals,
                    selectedJournalID: selectedJournal,
                    onSaveComplete: {
                        onSaveComplete() //Refresh journal list in HomeView
                        isAddingEntry = false
                    }
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
    @State static var selectedTag: String? = "Tag1"
    static var previews: some View {
        TopNavBarView(
            onSaveComplete: {},
            isSidebarOpen: .constant(false),
            selectedJournal: .constant("Personal"),
            journals: .constant([
                Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date()),
                Journal(id: "2", userID: "user1", title: "Work", createdAt: Date())
            ]),
            selectedTag: $selectedTag,
            onSearch: {},
            tags: [
                Tag(id: "tag1", name: "Tag1", colorHex: "#FF0000"),
                Tag(id: "tag2", name: "Tag2", colorHex: "#00FF00")
            ]
        )
    }
}

