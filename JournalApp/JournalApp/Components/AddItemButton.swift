//
//  AddItemButton.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-29.
//

import SwiftUI

struct AddItemButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle")
                Text(title)
            }
            .foregroundColor(.purple)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
    }
}

struct AddItemButton_Previews: PreviewProvider {
    static var previews: some View {
        AddItemButton(title: "Example Title", action: {})
    }
}
