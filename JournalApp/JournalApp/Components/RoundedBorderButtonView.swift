//
//  RoundedBorderButtonView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-28.
//

import SwiftUI

struct RoundedBorderButtonView: View {
    let title: String
    let action: () -> Void
    let backgroundColor: Color
    let borderColor: Color
    let textColor: Color

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(borderColor, lineWidth: 1)
                )
                .cornerRadius(999)
        }
    }
}

struct RoundedBorderButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedBorderButtonView(
            title: "Primary",
            action: { print("Primary tapped") },
            backgroundColor: Color(hex: "#1A1F3B"),
            borderColor: .clear,
            textColor: .white
        )
    }
}
