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
    let borderColor: Color?
    let textColor: Color
    let horizontalPadding: CGFloat?
    let verticalPadding: CGFloat?
    
    
    init(
        title: String,
        action: @escaping () -> Void,
        backgroundColor: Color,
        borderColor: Color? = nil,
        textColor: Color,
        horizontalPadding: CGFloat = 24,
        verticalPadding: CGFloat = 12
    ) {
        self.title = title
        self.action = action
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.textColor = textColor
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(borderColor ?? .clear, lineWidth: 1)
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
            borderColor: Color.clear,
            textColor: .white
        )
    }
}
