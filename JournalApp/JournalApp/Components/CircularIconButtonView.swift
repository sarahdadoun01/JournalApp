//
//  CircularIconButtonView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-29.
//

import SwiftUI

struct CircularIconButtonView: View {
    let systemName: String
    let size: CGFloat
    let padding: CGFloat
    let backgroundColor: Color
    let borderColor: Color
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .padding(padding)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .foregroundColor(iconColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: 1)
                )
        }
    }
}

struct CircularIconButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CircularIconButtonView(
            systemName: "plus",
            size: 50,
            padding: 18,
            backgroundColor: .clear,
            borderColor: Color(hex: "#B9B9B9"),
            iconColor: .black
        ) {
            print("Plus tapped")
        }
    }
}
