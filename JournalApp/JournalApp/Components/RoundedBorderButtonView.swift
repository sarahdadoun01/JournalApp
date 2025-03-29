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

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color.clear)
                .foregroundColor(Color(hex: "#1A1F3B")) // Midnight Blue
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(Color(hex: "#B9B9B9"), lineWidth: 1)
                )
                .cornerRadius(999)
        }
    }
}

struct RoundedBorderButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedBorderButtonView(
            title: "Preview Button",
            action: {
                print("Button tapped")
            }
        )
    }
}
