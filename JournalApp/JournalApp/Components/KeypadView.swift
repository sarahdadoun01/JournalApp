//
//  KeypadView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-26.
//

import SwiftUI

struct KeypadView: View {
    var onDigit: (String) -> Void
    var onBiometric: () -> Void
    var onDelete: () -> Void

    let buttonSize: CGFloat = 60
    let buttonSpacing: CGFloat = 40
    
    var body: some View {
        VStack(spacing: buttonSpacing) {
            HStack(spacing: buttonSpacing) {
                DigitButton(digit: "1", onTap: onDigit)
                DigitButton(digit: "2", onTap: onDigit)
                DigitButton(digit: "3", onTap: onDigit)
            }
            HStack(spacing: buttonSpacing) {
                DigitButton(digit: "4", onTap: onDigit)
                DigitButton(digit: "5", onTap: onDigit)
                DigitButton(digit: "6", onTap: onDigit)
            }
            HStack(spacing: buttonSpacing) {
                DigitButton(digit: "7", onTap: onDigit)
                DigitButton(digit: "8", onTap: onDigit)
                DigitButton(digit: "9", onTap: onDigit)
            }
            HStack(spacing: buttonSpacing) {
                // Face ID Button
                Button(action: onBiometric) {
                    Image(systemName: "faceid")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .frame(width: buttonSize, height: buttonSize)
                }
                
                // Zero
                DigitButton(digit: "0", onTap: onDigit)
                
                // Delete
                Button(action: onDelete) {
                    Image(systemName: "delete.left")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .frame(width: buttonSize, height: buttonSize)
                }
            }
        }
    }
}

struct Keypad_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            KeypadView(
                onDigit: { _ in },
                onBiometric: { },
                onDelete: { }
            )
        }
    }
}
