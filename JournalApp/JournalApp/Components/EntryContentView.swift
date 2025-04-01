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
    @Binding var selectedJournal: String?
    @Binding var blocks: [EntryBlock]


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // selected Journal
                if let journalTitle = selectedJournal {
                    Text(journalTitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                // Tags
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

                // Moods
                MoodsView(selectedMoods: selectedMoods)

                // Content Blocks
                ForEach($blocks.indices, id: \.self) { index in
                    let block = $blocks[index]
                    
                    switch block.wrappedValue.type {
                    case .text:
                        TextEditor(text: block.content)
                            .frame(minHeight: 100)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        
                    case .image:
                        if let uiImage = UIImage(named: block.wrappedValue.content) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        
                    case .audio:
                        AudioPlaybackView(audioFileName: block.wrappedValue.content)
                        
                    case .video:
                        VideoBlockView(videoFileName: block.wrappedValue.content)
                    }
                }

                Spacer().frame(height: 100)
            }
        }
    }
}

struct AudioPlaybackView: View {
    var audioFileName: String
    var body: some View {
        Text("🎧 Audio: \(audioFileName)")
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
    }
}

struct VideoBlockView: View {
    var videoFileName: String
    var body: some View {
        Text("🎬 Video: \(videoFileName)")
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
    }
}


struct EntryContentView_Previews: PreviewProvider {
    @State static var text = "Dear Journal, today was wild..."
    @State static var tags = ["grateful", "focus"]
    @State static var moods = ["happy", "tired"]
    @State static var media = [UIImage(systemName: "photo")!, UIImage(systemName: "photo.fill")!]
    @State static var selectedJournal: String?
    @State static var blocks: [EntryBlock] = [
        EntryBlock(type: .text, content: "Sample text block"),
        EntryBlock(type: .image, content: "sample-image"),
        EntryBlock(type: .audio, content: "audio-file-name"),
        EntryBlock(type: .video, content: "video-file-name")
    ]

    static var previews: some View {
        EntryContentView(
            mainText: $text,
            selectedTags: $tags,
            selectedMoods: $moods,
            selectedMediaFiles: $media,
            selectedJournal: $selectedJournal,
            blocks: $blocks
        )
    }
}

