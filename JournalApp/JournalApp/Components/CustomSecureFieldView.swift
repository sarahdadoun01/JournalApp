//
//  CustomSecureFieldView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-29.
//

import SwiftUI

struct CustomSecureFieldView: View {
    @Binding var text: String
    var placeholder: String

    var horizontalPadding: CGFloat = 12
    var verticalPadding: CGFloat = 12
    var cornerRadius: CGFloat = 10
    var backgroundColor: Color = Color(.systemGray6)
    var borderColor: Color = .clear
    var textColor: Color = .primary
    var font: Font = .body
    var onTextChange: ((String) -> Void)? = nil

    @State private var isSecure: Bool = true

    var body: some View {
        ZStack(alignment: .trailing) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .font(font)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
                }

                Group {
                    if isSecure {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                    }
                }
                .font(font)
                .foregroundColor(textColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .onChange(of: text) { newValue in
                    onTextChange?(newValue)
                }
            }

            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
                    .padding(.trailing, horizontalPadding)
            }
        }
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 1)
        )
        .cornerRadius(cornerRadius)
    }
}



struct CustomSecureFieldView_Previews: PreviewProvider {
    @State static var previewPassword: String = ""

    static var previews: some View {
        CustomSecureFieldView(
            text: $previewPassword,
            placeholder: "Password"
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
