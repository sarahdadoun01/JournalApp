//
//  MediaGridScrollView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//

import SwiftUI
import AVKit

struct MediaGridScrollView: View {
    var mediaItems: [MediaFile]
    let maxVisibleItems: Int = 4
    var onTapMore: (() -> Void)?
    
    var visibleItems: [MediaFile] {
        Array(mediaItems.prefix(maxVisibleItems))
    }

    var overflowCount: Int {
        max(mediaItems.count - maxVisibleItems, 0)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(visibleItems) { item in
                    ZStack {
                        if item.fileType == .image {
                            Image(uiImage: UIImage(contentsOfFile: item.fileURL) ?? UIImage())
                                .resizable()
                                .scaledToFill()
                        } else if item.fileType == .video {
                            VideoThumbnailView(videoURL: URL(fileURLWithPath: item.fileURL))
                        }
                    }
                    .frame(width: 65, height: 65)
                    .clipped()
                    .cornerRadius(10)
                }

                if overflowCount > 0 {
                    Button {
                        onTapMore?()
                    } label: {
                        ZStack {
                            Color.gray.opacity(0.2)
                            Text("+\(overflowCount)")
                                .font(.headline)
                        }
                        .frame(width: 65, height: 65)
                        .background(Color(hex: "#B6B6B6"))
                        .cornerRadius(10)
                        
                    }
                }
            }
            .padding(.horizontal,8)
            .padding(.vertical,8)
        }.background(.gray)
    }
}

struct MediaGridScrollView_Previews: PreviewProvider {
    static var previews: some View {
        let imagePath = Bundle.main.path(forResource: "sample-image", ofType: "png") ?? ""
        let videoPath = Bundle.main.path(forResource: "sample-video", ofType: "mp4") ?? ""
        
        let sampleItems: [MediaFile] = [
            MediaFile(id: "1", entryID: "entry1", fileURL: imagePath, fileType: .image),
            MediaFile(id: "2", entryID: "entry1", fileURL: imagePath, fileType: .image),
            MediaFile(id: "3", entryID: "entry1", fileURL: videoPath, fileType: .video),
            MediaFile(id: "4", entryID: "entry1", fileURL: videoPath, fileType: .video),
            MediaFile(id: "5", entryID: "entry1", fileURL: videoPath, fileType: .video),
        ]
        
        MediaGridScrollView(mediaItems: sampleItems)
    }
}
