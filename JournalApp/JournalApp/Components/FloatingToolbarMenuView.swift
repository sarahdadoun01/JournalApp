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
    var onTakePhoto: () -> Void
    var onAddVoiceMemo: () -> Void
    var onAddTag: (String) -> Void
    var onSelectJournal: () -> Void
    
    @State private var isVisible: Bool = true
    
    //@State private var showAddTagSheet = false
    @Binding var selectedJournalID: String?
    @Binding var selectedTags: [String]
    //new -test
    @Binding var moodButtonFrame: CGRect
    @Binding var formatButtonFrame: CGRect
    @Binding var activeInlinePopup: InlinePopupType?
    @Binding var showAddTagSheet: Bool
    @Binding var userTags: [String]

    
    var journals: [Journal]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isVisible {
                HStack(spacing: 20) {
//                    ToolbarButton(icon: "face.smiling", action: onAddMood)
                    // Mood Button
                    Button {
                        withAnimation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                activeInlinePopup = .moodPicker
                            }
                        }
                    } label: {
                        Image(systemName: "face.smiling")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 35, height: 25)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            let newFrame = geo.frame(in: .global)
                                            print("📍Mood button frame set onAppear: \(newFrame)")
                                            if moodButtonFrame != newFrame {
                                                DispatchQueue.main.async {
                                                    moodButtonFrame = newFrame
                                                }
                                            }
                                        }
                                }
                            )
                    }


                    // Formatting button
                    Button {
                        withAnimation {
                            activeInlinePopup = .formattingToolbar
                        }
                    } label: {
                        Image(systemName: "textformat")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 35, height: 25)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            let frame = geo.frame(in: .global)
                                            print("📍Format button frame set onAppear: \(frame)")
                                            DispatchQueue.main.async {
                                                formatButtonFrame = frame
                                            }
                                        }
                                }
                            )
                    }

                    ToolbarButton(icon: "mic", action: onAddVoiceMemo)

                    // Media menu
                    Menu {
                        Button("From Library", action: onAddImage)
                        Button("Take a Photo", action: onTakePhoto)
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
                                    selectedTags.removeAll { $0 == tag }
                                } else {
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

                        Button {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showAddTagSheet = true
                            }
                        } label: {
                            Text("+ Add Tag")
                                .frame(maxWidth: .infinity, alignment: .leading)
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



                    // Journal menu
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
    @State static var selectedTags: [String] = ["Tag1"]
    @State static var moodButtonFrame: CGRect = .zero
    @State static var formatButtonFrame: CGRect = .zero
    @State static var activeInlinePopup: InlinePopupType? = nil
    @State static var showAddTagSheet = false
    @State static var userTags: [String] = []

    static var previews: some View {
        FloatingToolbarMenuView(
            onAddMood: {
                activeInlinePopup = .moodPicker
            },
            onAddText: {},
            onAddImage: {},
            onTakePhoto: {},
            onAddVoiceMemo: {},
            onAddTag: { tag in
                if !selectedTags.contains(tag) {
                    selectedTags.append(tag)
                }
            },
            onSelectJournal: {},
            selectedJournalID: $selectedJournalID,
            selectedTags: $selectedTags,
            moodButtonFrame: $moodButtonFrame,
            formatButtonFrame: $formatButtonFrame,
            activeInlinePopup: $activeInlinePopup,
            showAddTagSheet: $showAddTagSheet,
            userTags: $userTags,
            journals: [
                Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date(), colorHex: "#FF5733"),
                Journal(id: "2", userID: "user1", title: "Work", createdAt: Date(), colorHex: "#33A1FF")
            ]
        )
        .previewLayout(.sizeThatFits)
    }
}
