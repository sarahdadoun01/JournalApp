//
//  FlexibleView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-07.
//

import SwiftUI

struct FlexibleView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Array(self.data.enumerated()), id: \.element) { index, item in
                self.content(item)
                    .padding(.trailing, spacing / 2)
                    .padding(.leading, index == 0 ? 0 : spacing / 2)
                    .fixedSize()
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > g.size.width {
                            width = 0
                            height -= dimension.height + spacing
                        }
                        let result = width
                        if index == self.data.count - 1 {
                            width = 0 // reset for next layout pass
                        } else {
                            width -= dimension.width + spacing
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if index == self.data.count - 1 {
                            height = 0 // reset for next layout pass
                        }
                        return result
                    })
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ViewHeightKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(ViewHeightKey.self) { value in
            self.totalHeight = value
        }
    }
}

private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
