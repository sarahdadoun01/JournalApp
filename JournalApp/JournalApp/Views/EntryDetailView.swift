//
//  EntryDetailView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-14.
//

import SwiftUI

struct EntryDetailView: View {
    let entry: Entry
    let blocks: [EntryBlock]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(entry.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 16)

                Text(formatDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.gray)

                ForEach(blocks) { block in
                    switch block.type {
                    case .text:
                        Text(block.content)
                            .font(.body)
                            .foregroundColor(.primary)
                    case .image:
                        if let url = URL(string: block.content) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(12)
                                } else if phase.error != nil {
                                    Text("⚠️ Failed to load image")
                                } else {
                                    ProgressView()
                                }
                            }
                        }
                    case .video:
                        // Placeholder – you could use AVKit VideoPlayer
                        Text("🎥 Video block")
                    case .audio:
                        AudioPlaybackView(
                            block: block,
                            entryID: nil,
                            blocks: .constant([]), // or pass the actual blocks array if you want delete/rename to work
                            showTitleAndSlider: true
                        )

                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Entry")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EntryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EntryDetailView(
            entry: Entry(
                id: "1",
                journalID: "journal1",
                userID: "user1",
                title: "A Day in My Life",
                content: "summary",
                date: Date(),
                moods: ["😊", "😴"],
                mediaFiles: [],
                tags: []
            ),
            blocks: [
                EntryBlock(type: .text, content: "This morning I had coffee."),
                EntryBlock(type: .image, content: "https://via.placeholder.com/300"),
                EntryBlock(type: .audio, content: "https://example.com/audio.m4a")
            ]
        )
    }
}
