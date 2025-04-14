//
//  TagsFlowLayout.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//


//
//  TagsFlowLayout.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//

import SwiftUI

struct TagsFlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var tags: Data
    var spacing: CGFloat
    var content: (Data.Element) -> Content
    
    

    
    @State private var appearedTags: Set<Data.Element> = []

    init(tags: Data, spacing: CGFloat = 6, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.tags = tags
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        let tagArray = Array(tags)

            return FlexibleView(data: tagArray, spacing: spacing) { tag in
                content(tag)
                    .scaleEffect(appearedTags.contains(tag) ? 1 : 0.5)
                    .opacity(appearedTags.contains(tag) ? 1 : 0)
                    .animation(
                        .interpolatingSpring(stiffness: 300, damping: 20)
                            .delay(Double(tagArray.firstIndex(of: tag) ?? 0) * 0.02),
                        value: appearedTags
                    )
                    .onAppear {
                        appearedTags.insert(tag)
                    }
                    .fixedSize()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TagsFlowLayout_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags:")
                .font(.headline)

            TagsFlowLayout(tags: ["#happy", "#FirstTagTest", "#grateful", "#focus", "#redtag", "#bluetag"]) { tag in
                Text(tag)
                    .font(.subheadline)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(100)
                    .fixedSize()
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
