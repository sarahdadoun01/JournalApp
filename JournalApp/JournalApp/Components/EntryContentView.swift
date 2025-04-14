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
    @Binding var selectedTab: Int
    @Binding var entryID: String?
    @Binding var showAddTagSheet: Bool
    @Binding var userTags: [String]
    @Binding var showInlineJournalPicker: Bool
    @Binding var isRecordingAudio: Bool

    @State private var showFullMediaViewer = false

    @FocusState private var localTextFocus: Bool

    // Extract image URLs from blocks
    private var imageURLs: [String] {
        blocks.filter { $0.type == .image }.map { $0.content }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            EntryContentMainView(
                mainText: $mainText,
                selectedTags: $selectedTags,
                selectedMoods: $selectedMoods,
                selectedMediaFiles: $selectedMediaFiles,
                selectedJournalID: $selectedJournalID,
                entryID: $entryID,
                blocks: $blocks,
                renderMarkdown: $renderMarkdown,
                showAddTagSheet: $showAddTagSheet,
                userTags: $userTags,
                journals: $journals,
                isTextEditorFocused: $isTextEditorFocused,
                showInlineJournalPicker: $showInlineJournalPicker
            )
            .tag(0)

            EntryContentMediaTabView(
                blocks: $blocks,
                entryID: $entryID,
                isRecordingAudio: $isRecordingAudio,
                onShowAll: {
                    showFullMediaViewer = true
                }
            )
            .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: selectedTab)
        .ignoresSafeArea(edges: .bottom)
        
        HStack(spacing: 8) {
            Circle()
                .fill(selectedTab == 0 ? .primary : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            Circle()
                .fill(selectedTab == 1 ? .primary : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
           }
           .padding(.top, 4)
           .padding(.bottom, 12)
    }

    // Optional: helper to programmatically switch tab from parent
    func switchToMediaTab() {
        selectedTab = 1
    }
}

struct EntryContentView_Previews: PreviewProvider {
    @State static var text = "Dear Journal, today was wild..."
    @State static var tags = ["grateful", "focus"]
    @State static var moods = ["happy", "tired"]
    @State static var media = [UIImage(systemName: "photo")!, UIImage(systemName: "photo.fill")!]
    @State static var selectedJournalID: String? = "1"
    @State static var journals: [Journal] = [
        Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date(), colorHex: "#FF5733"),
        Journal(id: "2", userID: "user1", title: "Work", createdAt: Date(), colorHex: "#33A1FF")
    ]
    @State static var blocks: [EntryBlock] = [
        EntryBlock(type: .text, content: "**This is a journal entry** with some _markdown_."),
        EntryBlock(type: .image, content: "https://via.placeholder.com/600x400.png?text=Image+1"),
        EntryBlock(type: .image, content: "https://via.placeholder.com/600x400.png?text=Image+2"),
        EntryBlock(type: .audio, content: "sample-audio.mp3"),
        EntryBlock(type: .video, content: "sample-video.mp4")
    ]
    @State static var showFormattedText = true
    @State static var childFocused = false
    @State static var selectedTab = 0
    @State static var entryID: String?
    @State static var showAddTagSheet = false
    @State static var userTags: [String] = ["Tag1", "Tag2"]
    @State static var showInlineJournalPicker = false
    @State static var isRecordingAudio = false

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
            isTextEditorFocused: $childFocused,
            selectedTab: $selectedTab,
            entryID: $entryID,
            showAddTagSheet: $showAddTagSheet,
            userTags: $userTags,
            showInlineJournalPicker: $showInlineJournalPicker,
            isRecordingAudio: $isRecordingAudio
        )
        .previewDisplayName("EntryContentView – With Tabs")
    }
}
