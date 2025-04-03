//
//  MediaPreviewView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-01.
//

import SwiftUI

struct MediaPreviewView: View {
    let mediaItems: [UIImage]
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex: Int = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(mediaItems.enumerated()), id: \.offset) { index, image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .tag(index)
                    .ignoresSafeArea()
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 {
                        dismiss() // swipe down to dismiss
                    }
                }
        )
    }
}

struct MediaPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        MediaPreviewView(mediaItems: sampleImages)
            .background(Color(.systemGray6))

    }

    static var sampleImages: [UIImage] {
        (1...4).compactMap { _ in UIImage(systemName: "photo") }
    }
}

