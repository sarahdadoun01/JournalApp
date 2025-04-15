//
//  EntryContentMainView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-08.
//

import SwiftUI

struct EntryContentMainView: View {
    @Binding var mainText: String
    @Binding var selectedTags: [String]
    @Binding var selectedMoods: [String]
    @Binding var selectedMediaFiles: [UIImage]
    @Binding var selectedJournalID: String?
    @Binding var blocks: [EntryBlock]
    @Binding var renderMarkdown: Bool
    @Binding var journals: [Journal]
    @Binding var isTextEditorFocused: Bool
    @Binding var entryID: String?
    @Binding var showAddTagSheet: Bool
    @Binding var userTags: [String]
    @Binding var showInlineJournalPicker: Bool

    @FocusState private var localTextFocus: Bool
    
    


    // Combine images and videos into one media file array    
    private var mediaFiles: [MediaFile] {
        let result = blocks.enumerated().compactMap { index, block in
            if block.type == .image || block.type == .video {
                return MediaFile(
                    id: "\(index)",
                    entryID: "current-entry",
                    fileURL: block.content,
                    fileType: block.type == .image ? .image : .video
                )
            }
            return nil
        }

        result.forEach { print("• \($0.fileURL)") }

        return result
    }

    
    init(
        mainText: Binding<String>,
        selectedTags: Binding<[String]>,
        selectedMoods: Binding<[String]>,
        selectedMediaFiles: Binding<[UIImage]>,
        selectedJournalID: Binding<String?>,
        entryID: Binding<String?>,
        blocks: Binding<[EntryBlock]>,
        renderMarkdown: Binding<Bool>,
        showAddTagSheet: Binding<Bool>,
        userTags: Binding<[String]>,
        journals: Binding<[Journal]>,
        isTextEditorFocused: Binding<Bool>,
        showInlineJournalPicker: Binding<Bool>
    ) {
        self._mainText = mainText
        self._selectedTags = selectedTags
        self._selectedMoods = selectedMoods
        self._selectedMediaFiles = selectedMediaFiles
        self._selectedJournalID = selectedJournalID
        self._entryID = entryID
        self._blocks = blocks
        self._renderMarkdown = renderMarkdown
        self._showAddTagSheet = showAddTagSheet
        self._userTags = userTags
        self._journals = journals
        self._isTextEditorFocused = isTextEditorFocused
        self._showInlineJournalPicker = showInlineJournalPicker
        
    }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                
                
                // Journal title
                if let journalID = selectedJournalID {
                    Menu {
                        Button {
                            selectedJournalID = "all"
                        } label: {
                            HStack {
                                Image(systemName: "tray.full")
                                Text("All Journals")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if selectedJournalID?.lowercased() == "all" {
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
                                        .fill(Color(hex: journal.colorHex))
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
                        HStack(spacing: 8) {
                            if selectedJournalID?.lowercased() == "all" {
                                Image(systemName: "tray.full")
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(.secondary)
                                Text("All Journals")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else if let journal = journals.first(where: { $0.id == selectedJournalID }) {
                                let journalColor = Color(hex: journal.colorHex)
                                Circle().fill(journalColor).frame(width: 8, height: 8)
                                Text(journal.title)
                                    .font(.caption)
                                    .foregroundColor(journalColor)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                }

                // Tags
                if !selectedTags.isEmpty {
                    TagsFlowLayout(tags: selectedTags, spacing: 5) { tag in
                        Text("#\(tag)")
                            .font(.subheadline)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.primary)
                            .cornerRadius(100)
                            .fixedSize()
                    }
                    .padding(.top, 8)
                }

                // Moods
                MoodsView(selectedMoods: selectedMoods)

                // Markdown toggle
                Toggle(isOn: $renderMarkdown) {
                    Text("Render Markdown")
                        .font(.subheadline)
                }
                .toggleStyle(.switch)

                // Text and audio blocks
                ForEach($blocks.indices, id: \.self) { index in
                    let block = $blocks[index]

                    switch block.wrappedValue.type {
                    case .text:
                        MarkdownTextView(
                            text: $blocks[index].content,
                            renderMarkdown: renderMarkdown
                        )
                        .background(Color.yellow.opacity(0.1))
                        .border(Color.red.opacity(0.2))
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        .focused($localTextFocus)
                        .onTapGesture {
                            localTextFocus = true
                        }
                        .onChange(of: localTextFocus) { isFocused in
                            isTextEditorFocused = isFocused
                        }

//                    case .audio:
//                        AudioPlaybackView(
//                            block: blocks[index],
//                            entryID: entryID,
//                            blocks: $blocks,
//                            showTitleAndSlider: false
//                        )

                    default:
                        EmptyView()
                    }
                }

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 100)
        }
    }
}


struct EntryContentMainView_Previews: PreviewProvider {
    @State static var text = "Dear Journal, today was wild..."
    @State static var tags = ["grateful", "focus"]
    @State static var moods = ["happy", "tired"]
    @State static var media = [UIImage(systemName: "photo")!]
    @State static var selectedJournalID: String? = "1"
    @State static var entryID: String? = "preview-entry-id"
    @State static var blocks: [EntryBlock] = [
        EntryBlock(type: .text, content: "**Bold** and _italic_ text here."),
        EntryBlock(type: .image, content: "https://via.placeholder.com/600x400.png?text=Image+1"),
        EntryBlock(type: .audio, content: "audio-file-name"),
        EntryBlock(type: .video, content: "video-file-name")
    ]
    @State static var renderMarkdown = true
    @State static var showAddTagSheet = false
    @State static var userTags: [String] = ["focus", "study"]
    @State static var journals: [Journal] = [
        Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date()),
        Journal(id: "2", userID: "user1", title: "Work", createdAt: Date())
    ]
    @State static var childFocused = false
    @State static var showInlineJournalPicker = false

    static var previews: some View {
        EntryContentMainView(
            mainText: $text,
            selectedTags: $tags,
            selectedMoods: $moods,
            selectedMediaFiles: $media,
            selectedJournalID: $selectedJournalID,
            entryID: $entryID,
            blocks: $blocks,
            renderMarkdown: $renderMarkdown,
            showAddTagSheet: $showAddTagSheet,
            userTags: $userTags,
            journals: $journals,
            isTextEditorFocused: $childFocused,
            showInlineJournalPicker: $showInlineJournalPicker
        )
    }
}
