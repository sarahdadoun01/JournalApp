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

    @FocusState private var localTextFocus: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Show selected journal at top
                if let journalID = selectedJournalID,
                   let journal = journals.first(where: { $0.id == journalID }) {
                    let journalColorHex = journal.colorHex ?? "#6432a8"
                    let journalColor = Color(hex: journalColorHex)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(journalColor)
                            .frame(width: 8, height: 8)
                        Text(journal.title)
                            .font(.caption)
                            .foregroundColor(journalColor)
                    }
                    .padding(.top, 5)
                } else if selectedJournalID == "All" {
                    HStack(spacing: 8) {
                        Image(systemName: "tray.full")
                            .frame(width: 8, height: 8)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 3)
                        Text("All Journals")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 5)
                }

                // Tags
                if !selectedTags.isEmpty {
                    TagsFlowLayout(tags: selectedTags, spacing: 3) { tag in
                        Text("#\(tag)")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }

                // Moods
                MoodsView(selectedMoods: selectedMoods)

                // Markdown toggle
                Toggle(isOn: $renderMarkdown) {
                    Label("Render Markdown", systemImage: "")
                        .font(.subheadline)
                }
                .toggleStyle(.switch)

                // Blocks
                ForEach($blocks.indices, id: \.self) { index in
                    let block = $blocks[index]

                    switch block.wrappedValue.type {
                    case .text:
                        MarkdownTextView(
                            text: $blocks[index].content,
                            renderMarkdown: renderMarkdown
                        )
                        .focused($localTextFocus)
                        .onTapGesture {
                            localTextFocus = true
                        }
                        .onChange(of: localTextFocus) { newValue in
                            isTextEditorFocused = newValue
                        }

                    case .image:
                        if let url = URL(string: block.wrappedValue.content) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty: ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                case .failure:
                                    Image(systemName: "xmark.octagon")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }

                    case .audio:
                        AudioPlaybackView(audioFileName: block.wrappedValue.content)

                    case .video:
                        VideoBlockView(videoFileName: block.wrappedValue.content)
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
    @State static var selectedJournalID: String?
    @State static var journals: [Journal] = [
        Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date()),
        Journal(id: "2", userID: "user1", title: "Work", createdAt: Date())
    ]
    @State static var blocks: [EntryBlock] = [
        EntryBlock(type: .text, content: "**Bold** and _italic_ text here."),
        EntryBlock(type: .image, content: "https://via.placeholder.com/600x400.png?text=Image+1"),
        EntryBlock(type: .audio, content: "audio-file-name"),
        EntryBlock(type: .video, content: "video-file-name")
    ]
    @State static var showFormattedText = true
    @State static var childFocused = false

    static var previews: some View {
        EntryContentMainView(
            mainText: $text,
            selectedTags: $tags,
            selectedMoods: $moods,
            selectedMediaFiles: $media,
            selectedJournalID: $selectedJournalID,
            blocks: $blocks,
            renderMarkdown: $showFormattedText,
            journals: $journals,
            isTextEditorFocused: $childFocused
        )
    }
}
