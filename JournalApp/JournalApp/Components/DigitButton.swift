//
//  DigitButton.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-26.
//

import SwiftUI

struct DigitButton: View {
    let digit: String
    let onTap: (String) -> Void

    var body: some View {
        Button(action: {
            onTap(digit)
        }) {
            Text(digit)
                .font(.largeTitle)
                .foregroundColor(.black)
                .frame(width: 60, height: 60)
        }
    }
}

struct DigitButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            DigitButton(digit: "5") { _ in }
        }
    }
}
