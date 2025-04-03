//
//  EntryMediaView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-01.
//

import SwiftUI

struct EntryMediaView: View {
    let mediaItems: [UIImage]
    let maxVisibleItems = 6
    let onShowAll: () -> Void

    var body: some View {
        let count = mediaItems.count
        let displayItems = mediaItems.prefix(maxVisibleItems)
        let extraCount = count - maxVisibleItems

        if count == 1, let image = mediaItems.first {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
        } else if count == 2 {
            VStack(spacing: 8) {
                ForEach(Array(displayItems.enumerated()), id: \.offset) { _, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(width: UIScreen.main.bounds.width / 2 - 24)
                        .clipped()
                        .cornerRadius(10)
                }
            }
        } else {
            let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(displayItems.enumerated()), id: \.offset) { index, image in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(10)

                        if index == maxVisibleItems - 1 && extraCount > 0 {
                            Rectangle()
                                .foregroundColor(Color.black.opacity(0.6))
                                .cornerRadius(10)

                            Text("+\(extraCount)")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .onTapGesture {
                        if index == maxVisibleItems - 1 && extraCount > 0 {
                            onShowAll()
                        }
                    }
                }
            }
        }
    }
}


struct EntryMediaView_Previews: PreviewProvider {
    static var previews: some View {
        EntryMediaView(
            mediaItems: sampleImages,
            onShowAll: {
                print("Tapped to show all media")
            }
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color(.systemGray6))
    }

    static var sampleImages: [UIImage] {
        (1...8).compactMap { _ in UIImage(systemName: "photo") }
    }
}

