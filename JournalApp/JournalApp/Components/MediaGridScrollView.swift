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
    var onTapMore: (() -> Void)?
    
    var visibleItems: [MediaFile] {
        mediaItems
    }


    var body: some View {
        
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 8) {
                
                ForEach(Array(visibleItems.enumerated()), id: \.offset) { index, item in
                    ZStack {
                        if item.fileType == .image {
                            if let url = URL(string: item.fileURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Image(systemName: "xmark.octagon")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.red)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        } else if item.fileType == .video {
                            VideoThumbnailView(videoURL: URL(string: item.fileURL)!)
                        }
                    }
                    .frame(width: 65, height: 65)
                    .clipped()
                    .cornerRadius(10)
                }


            }
            .padding(.horizontal,8)
            .padding(.vertical,8)
            
        }.padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(40)
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
