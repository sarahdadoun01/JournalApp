//
//  TextFormattingToolbarView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-01.
//

// TextFormattingToolbarView.swift

import SwiftUI

struct TextFormattingToolbarView: View {
    let onFormat: (TextFormatStyle) -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button(action: { onFormat(.bold) }) {
                Image(systemName: "bold")
            }
            Button(action: { onFormat(.italic) }) {
                Image(systemName: "italic")
            }
            Button(action: { onFormat(.underline) }) {
                Image(systemName: "underline")
            }
            Button(action: { onFormat(.listBullet) }) {
                Image(systemName: "list.bullet")
            }
            Button(action: { onFormat(.listNumber) }) {
                Image(systemName: "list.number")
            }

            Divider().frame(height: 24)

            Button(action: { onFormat(.increaseSize) }) {
                Text("A+").font(.headline)
            }
            Button(action: { onFormat(.decreaseSize) }) {
                Text("A−").font(.headline)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 0)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct TextFormattingToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        TextFormattingToolbarView { style in
            print("Preview format: \(style)")
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
