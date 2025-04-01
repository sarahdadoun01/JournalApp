//
//  TagsFlowLayout.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//

import SwiftUI

struct TagsFlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content

    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            content()
                .fixedSize()
                .alignmentGuide(.leading) { dimension in
                    if abs(width - dimension.width) > geometry.size.width {
                        width = 0
                        height -= dimension.height + spacing
                    }
                    let result = width
                    if dimension.width != 0 {
                        width -= dimension.width + spacing
                    }
                    return result
                }
                .alignmentGuide(.top) { _ in
                    let result = height
                    if width == 0 {
                        height -= spacing
                    }
                    return result
                }
        }
    }
}


struct TagsFlowLayout_Previews: PreviewProvider {
    static var previews: some View {
        TagsFlowLayout {
            ForEach(["happy", "sad", "excited", "tired"], id: \.self) { mood in
                Text(mood)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
