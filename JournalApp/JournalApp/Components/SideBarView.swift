//
//  SideBarView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

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
                    .onTapGesture { isShowing = false } // Close when tapping outside
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        // Journals Section
                        Text("Journals")
                            .font(.headline)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
//
//                        Button(action: {
//                            onSelectJournal("All")
//                            isShowing = false
//                        }) {
//                            Label("All", systemImage: "book.closed")
//                        }
//                        .padding()

                        ForEach(journals, id: \.id) { journal in
                            Button(action: {
                                onSelectJournal(journal.title)
                                isShowing = false
                            }) {
                                Label(journal.title, systemImage: "book")
                            }
                            .padding(.leading, 15)
                        }

                        Divider().padding(.vertical, 10)

                        // Tags Section
                        Text("Tags")
                            .font(.headline)
                            .padding(.bottom, 10)

                        ForEach(tags, id: \.self) { tag in
                            Button(action: {}) {
                                Label(tag, systemImage: "tag")
                            }
                            .padding(.leading, 15)
                        }

                        Divider().padding(.vertical, 10)

                        // Settings
                        Button(action: {}) {
                            Label("Settings", systemImage: "gear")
                        }
                        .padding(.leading, 15)

                        Spacer()
                    }.padding(.top, 50)
                    .padding(.leading, 20)
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.all)

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
            isShowing: .constant(true), // Use .constant() for bindings
            selectedJournal: .constant("All"), // Sample journal selection
            
            journals: [
                Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date()),
                Journal(id: "2", userID: "user1", title: "Work", createdAt: Date())
            ], // Sample journal list
            
            tags: ["Work", "Personal", "Ideas"], // Sample tags
            
            onSelectJournal: { _ in } // Dummy closure for journal selection
        )
        
    }
}

