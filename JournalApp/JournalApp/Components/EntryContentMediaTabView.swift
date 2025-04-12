//
//  EntryContentMediaTabView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-08.
//

import SwiftUI

struct EntryContentMediaTabView: View {
    @Binding var blocks: [EntryBlock]
    let onShowAll: () -> Void

    // Convert .image and .video blocks to MediaFile array
    private var mediaFiles: [MediaFile] {
        print("📦 Blocks being processed:")
        blocks.forEach { print("🧱 \($0.type) – \($0.content)") }

        return blocks.enumerated().compactMap { index, block in
            if block.type == .image || block.type == .video {
                return MediaFile(
                    id: "\(index)-\(block.content.hashValue)",
                    entryID: "media-tab",
                    fileURL: block.content,
                    fileType: block.type == .image ? .image : .video
                )
            }
            return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // keep blocks in order
                let mediaBlocks = blocks.filter {
                    $0.type == .image || $0.type == .video || $0.type == .audio
                }

                if mediaBlocks.isEmpty {
                    Text("No media yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(Array(mediaBlocks.enumerated()), id: \.offset) { _, block in
                        switch block.type {
                        case .image, .video:
                            MediaGridScrollView(
                                mediaItems: [
                                    MediaFile(
                                        id: UUID().uuidString,
                                        entryID: "media-tab",
                                        fileURL: block.content,
                                        fileType: block.type == .image ? .image : .video
                                    )
                                ],
                                onTapMore: onShowAll
                            )

                        case .audio:
                            AudioPlaybackView(audioFileName: block.content)

                        default:
                            EmptyView()
                        }
                    }
                }

                Spacer()
            }
            .padding(20)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }

}

struct EntryContentMediaTabView_Previews: PreviewProvider {
    @State static var blocks: [EntryBlock] = [
        EntryBlock(type: .image, content: "https://via.placeholder.com/600x400.png?text=Image+1"),
        EntryBlock(type: .video, content: "sample-video.mp4"),
        EntryBlock(type: .image, content: "https://via.placeholder.com/600x400.png?text=Image+2")
    ]
    
    static var previews: some View {
        EntryContentMediaTabView(
            blocks: $blocks,
            onShowAll: {}
        )
    }
}
