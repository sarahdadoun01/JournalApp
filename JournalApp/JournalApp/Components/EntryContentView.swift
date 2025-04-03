//
//  EntryContentView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//

import SwiftUI

struct EntryContentView: View {
    @Binding var mainText: String
    @Binding var selectedTags: [String]
    @Binding var selectedMoods: [String]
    @Binding var selectedMediaFiles: [UIImage]
    @Binding var selectedJournalID: String?
    @Binding var blocks: [EntryBlock]
    @Binding var renderMarkdown: Bool
    @Binding var journals: [Journal]
    @Binding var isTextEditorFocused: Bool

    @State private var showFullMediaViewer = false

    @FocusState private var localTextFocus: Bool

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Show selected journal
//                    if let journalID = selectedJournalID,
//                       let journal = journals.first(where: { $0.id == journalID }) {
//
//                        let journalColorHex = journal.colorHex ?? "#9C27B0"
//                        let journalColor = Color(hex: journalColorHex)
//
//                        Text(journal.title)
//                            .font(.title3)
//                            .foregroundColor(journalColor)
//                            .padding(.horizontal)
//                    }
                    
                    // Show selected journal at top in a styled header
                    if let journalID = selectedJournalID,
                       let journal = journals.first(where: { $0.id == journalID }) {

                        let journalColorHex = journal.colorHex ?? "#6432a8"
                        let journalColor = Color(hex: journalColorHex)

                        HStack(spacing: 8) {
                            Circle()
                                .fill(journalColor)
                                .frame(width: 12, height: 12)
                            Text(journal.title)
                                .font(.headline)
                                .foregroundColor(journalColor)
                        }
                        .padding(.top, 20)
                    } else if selectedJournalID == "all" {
                        HStack(spacing: 8) {
                            Image(systemName: "tray.full")
                                .foregroundColor(.secondary)
                            Text("All Journals")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                    }



                    // Show tags
                    if !selectedTags.isEmpty {
                        TagsFlowLayout(spacing: 8) {
                            ForEach(selectedTags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.subheadline)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Show moods
                    MoodsView(selectedMoods: selectedMoods)
                    
                    Toggle(isOn: $renderMarkdown) {
                        Label("Render Markdown", systemImage: "")
                            .font(.subheadline)
                    }
                    .toggleStyle(.switch)
                    .padding(.horizontal)

                    // Loop through content blocks
                    ForEach($blocks.indices, id: \.self) { index in
                        let block = $blocks[index]
                        
                        switch block.wrappedValue.type {
                        case .text:
                            MarkdownTextView(
                                text: $blocks[index].content,
                                renderMarkdown: renderMarkdown
                            )
                            .focused($localTextFocus)  // local focus
                            .onTapGesture {
                                // When tapped, focus this editor
                                localTextFocus = true
                            }
                            
                            // Keep the parent's isTextEditorFocused in sync with local focus
                            .onChange(of: localTextFocus) { newValue in
                                isTextEditorFocused = newValue
                            }

                        case .image:
                            EntryMediaView(
                                mediaItems: selectedMediaFiles,
                                onShowAll: { showFullMediaViewer = true }
                            )

                        case .audio:
                            AudioPlaybackView(audioFileName: block.wrappedValue.content)

                        case .video:
                            VideoBlockView(videoFileName: block.wrappedValue.content)
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
                .onAppear { // temp debug
                    print("Selected journal ID: \(selectedJournalID ?? "none")")
                    print("Available journals: \(journals.map(\.id))")
                }

            }
        }
    }
}

struct AudioPlaybackView: View {
    var audioFileName: String
    var body: some View {
        HStack {
            Text("🎧 Audio: \(audioFileName)")
                .padding(12)
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

struct VideoBlockView: View {
    var videoFileName: String
    var body: some View {
        HStack {
            Text("🎬 Video: \(videoFileName)")
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

struct EntryContentView_Previews: PreviewProvider {
    @State static var text = "Dear Journal, today was wild..."
    @State static var tags = ["grateful", "focus"]
    @State static var moods = ["happy", "tired"]
    @State static var media = [UIImage(systemName: "photo")!, UIImage(systemName: "photo.fill")!]
    @State static var selectedJournalID: String?
    @State static var journals: [Journal] = [
        Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date()),
        Journal(id: "2", userID: "user1", title: "Work", createdAt: Date())
    ]
    @State static var blocks: [EntryBlock] = [
        EntryBlock(type: .text, content: "**Bold** and _italic_ text here."),
        EntryBlock(type: .image, content: "sample-image"),
        EntryBlock(type: .audio, content: "audio-file-name"),
        EntryBlock(type: .video, content: "video-file-name")
    ]
    @State static var showFormattedText = true
    @State static var childFocused = false

    static var previews: some View {
        EntryContentView(
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
