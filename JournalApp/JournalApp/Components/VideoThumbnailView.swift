//
//  VideoThumbnailView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//

import SwiftUI
import AVFoundation

struct VideoThumbnailView: View {
    let videoURL: URL

    var thumbnail: UIImage {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        if let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: cgImage)
        } else {
            return UIImage(systemName: "video") ?? UIImage()
        }
    }

    var body: some View {
        Image(uiImage: thumbnail)
            .resizable()
            .scaledToFill()
    }
}
