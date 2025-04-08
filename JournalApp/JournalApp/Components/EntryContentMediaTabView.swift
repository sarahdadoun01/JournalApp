//
//  EntryContentMediaTabView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-08.
//

import SwiftUI

struct EntryContentMediaTabView: View {
    let imageURLs: [String]
    let onShowAll: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if imageURLs.isEmpty {
                    Text("No media yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    EntryMediaURLView(imageURLs: imageURLs, onShowAll: onShowAll)
                }

                Spacer()
            }
            .padding(20)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

struct EntryContentMediaTabView_Previews: PreviewProvider {
    static var previews: some View {
        EntryContentMediaTabView(
            imageURLs: sampleURLs,
            onShowAll: { print("Tapped to show all") }
        )
    }

    static let sampleURLs: [String] = [
        "https://via.placeholder.com/600x400.png?text=Image+1",
        "https://via.placeholder.com/600x400.png?text=Image+2",
        "https://via.placeholder.com/600x400.png?text=Image+3",
        "https://via.placeholder.com/600x400.png?text=Image+4",
        "https://via.placeholder.com/600x400.png?text=Image+5"
    ]
}
