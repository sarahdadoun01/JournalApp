//
//  SectionLabel.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-29.
//

import SwiftUI

struct SectionLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.gray)
            .padding(.top, 10)
    }
}

struct SectionLabel_Previews: PreviewProvider {
    static var previews: some View {
        SectionLabel("Section Here")
    }
}
