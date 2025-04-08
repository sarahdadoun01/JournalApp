//
//  EntryMediaURLView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-08.
//

import SwiftUI

struct EntryMediaURLView: View {
    let imageURLs: [String]
    let onShowAll: () -> Void

    let maxVisibleItems = 6

    var body: some View {
        let count = imageURLs.count
        let displayItems = imageURLs.prefix(maxVisibleItems)
        let extraCount = count - maxVisibleItems

        VStack(spacing: 12) {
            if count == 1, let url = URL(string: imageURLs.first!) {
                fullWidthImage(from: url)
            } else if count == 2 {
                ForEach(imageURLs, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        fullWidthImage(from: url)
                    }
                }
            } else {
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(displayItems.enumerated()), id: \.offset) { index, urlString in
                        if let url = URL(string: urlString) {
                            ZStack {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty: ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure: fallbackImage
                                    @unknown default: EmptyView()
                                    }
                                }
                                .frame(height: 100)
                                .clipped()
                                .cornerRadius(10)

                                if index == maxVisibleItems - 1 && extraCount > 0 {
                                    Rectangle()
                                        .foregroundColor(Color.black.opacity(0.5))
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
    }

    @ViewBuilder
    func fullWidthImage(from url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty: ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
            case .failure: fallbackImage
            @unknown default: EmptyView()
            }
        }
    }

    var fallbackImage: some View {
        Image(systemName: "xmark.octagon")
            .resizable()
            .scaledToFit()
            .foregroundColor(.red)
    }
}

struct EntryMediaURLView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            Text("1 Image")
            EntryMediaURLView(
                imageURLs: [sampleURLs[0]],
                onShowAll: {}
            )

            Text("2 Images (Full-width stack)")
            EntryMediaURLView(
                imageURLs: Array(sampleURLs.prefix(2)),
                onShowAll: {}
            )

            Text("3+ Images (Grid)")
            EntryMediaURLView(
                imageURLs: sampleURLs,
                onShowAll: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }

    static let sampleURLs: [String] = [
        "https://via.placeholder.com/600x400.png?text=Image+1",
        "https://via.placeholder.com/600x400.png?text=Image+2",
        "https://via.placeholder.com/600x400.png?text=Image+3",
        "https://via.placeholder.com/600x400.png?text=Image+4",
        "https://via.placeholder.com/600x400.png?text=Image+5",
        "https://via.placeholder.com/600x400.png?text=Image+6",
        "https://via.placeholder.com/600x400.png?text=Image+7"
    ]
}
