//
//  FloatingToolbarMenuView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-20.
//

import SwiftUI

struct MoodButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct FloatingToolbarMenuView: View {
    var onAddMood: () -> Void
    var onAddText: () -> Void
    var onAddImage: () -> Void
    var onAddVoiceMemo: () -> Void
    var onAddTag: (String) -> Void
    var onSelectJournal: () -> Void
    
    @State private var isVisible: Bool = true
    @State private var userTags: [String] = []
    @State private var showAddTagSheet = false
    
    @Binding var selectedJournalID: String?
    @Binding var selectedTags: [String]
    
    var journals: [Journal]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isVisible {
                HStack(spacing: 20) {
//                    ToolbarButton(icon: "face.smiling", action: onAddMood)
                    // Mood Button
                    Button {
                        activeInlinePopup = .moodPicker
                    } label: {
                        Image(systemName: "face.smiling")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 35, height: 25)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            let frame = geo.frame(in: .global)
                                            print("📍Mood button frame set onAppear: \(frame)")
                                            DispatchQueue.main.async {
                                                moodButtonFrame = frame
                                            }
                                        }
                                }
                            )
                    }



                    ToolbarButton(icon: "textformat", action: onAddText)
                    ToolbarButton(icon: "mic", action: onAddVoiceMemo)

                    // Media menu
                    Menu {
                        Button("From Library", action: onAddImage)
                        Button("Take a Photo") {
                            print("TODO: implement camera action")
                            // You can add a callback here later if you want
                        }
                    } label: {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 35, height: 25)
                    }

                    // Tag menu
                    Menu {
                        ForEach(userTags, id: \.self) { tag in
                            Button(action: {
                                if selectedTags.contains(tag) {
                                    // remove it if already selected
                                    selectedTags.removeAll { $0 == tag }
                                } else {
                                    // add if not already there
                                    selectedTags.append(tag)
                                    onAddTag(tag)
                                }
                            }) {
                                HStack {
                                    Text("#\(tag)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }

                        Divider()

                        Button(action: {
                            showAddTagSheet = true
                        }) {
                            HStack {
                                Text("+ Add Tag")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        if userTags.isEmpty {
                            Text("No tags found")
                                .foregroundColor(.gray)
                        }
                    } label: {
                        Image(systemName: "tag")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 35, height: 25)
                    }
                    .sheet(isPresented: $showAddTagSheet) {
                        AddTagView(
                            userID: FirebaseService.shared.currentUserID ?? "unknown",
                            onAddComplete: {
                                Task {
                                    userTags = try await FirebaseService.shared.fetchUserTags()
                                }
                                showAddTagSheet = false
                            }
                        )
                    }


                    // Journal menu (still uses onSelectJournal)
//                    Menu {
//                        ForEach(journals) { journal in
//                            Button {
//                                selectedJournalID = journal.id
//                            } label: {
//                                HStack {
//                                    Circle()
//                                        .fill(Color(hex: journal.colorHex ?? "#9C27B0"))
//                                        .frame(width: 12, height: 12)
//                                    Text(journal.title)
//                                }
//                            }
//                        }
//                    } label: {
//                        Image(systemName: "book")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                            .frame(width: 35, height: 25)
//                    }
                    Menu {
                        Button {
                            selectedJournalID = "all"
                        } label: {
                            HStack {
                                Image(systemName: "tray.full")
                                Text("All Journals")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if selectedJournalID == "all" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }

                        ForEach(journals) { journal in
                            Button {
                                selectedJournalID = journal.id
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(Color(hex: journal.colorHex ?? "#9C27B0"))
                                        .frame(width: 12, height: 12)
                                    Text(journal.title)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if selectedJournalID == journal.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "book")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 35, height: 25)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.2), radius: 10)
            }
        }
        .animation(.easeInOut, value: isVisible)
        .onAppear {
            Task {
                do {
                    userTags = try await FirebaseService().fetchUserTags()
                } catch {
                    print("Error fetching tags: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ToolbarButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
                .frame(width: 35, height: 25)
        }
    }
}

struct FloatingToolbarMenuView_Previews: PreviewProvider {
    @State static var selectedJournalID: String? = "1"
    @State static var selectedTags: [String] = []

    static var previews: some View {
        FloatingToolbarMenuView(
            onAddMood: {},
            onAddText: {},
            onAddImage: {},
            onAddVoiceMemo: {},
            onAddTag: { tag in
                if !selectedTags.contains(tag) {
                    selectedTags.append(tag)
                }
            },
            onSelectJournal: {},
            selectedJournalID: $selectedJournalID,
            selectedTags: $selectedTags,
            journals: [
                Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date(), colorHex: "#FF5733"),
                Journal(id: "2", userID: "user1", title: "Work", createdAt: Date(), colorHex: "#33A1FF")
            ]
        )
        .previewLayout(.sizeThatFits)
    }
}
