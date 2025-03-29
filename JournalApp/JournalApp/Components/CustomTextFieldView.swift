//
//  CustomTextFieldView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-29.
//

import SwiftUI

struct CustomTextFieldView: View {
    @Binding var text: String
    var placeholder: String
    var autocapitalization: TextInputAutocapitalization = .words
    var horizontalPadding: CGFloat = 12
    var verticalPadding: CGFloat = 12
    var cornerRadius: CGFloat = 10
    var backgroundColor: Color = Color(.systemGray5)
    var borderColor: Color = .clear
    var textColor: Color = .primary
    var font: Font = .body
    var onTextChange: ((String) -> Void)? = nil

    var body: some View {
        TextField("", text: $text)
            .textInputAutocapitalization(autocapitalization)
            .disableAutocorrection(true)
            .font(font)
            .foregroundColor(textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 1)
            )
            .cornerRadius(cornerRadius)
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
            }
            .onChange(of: text) { newValue in
                onTextChange?(newValue)
            }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder() }
            self
        }
    }
}

struct CustomTextFieldView_Previews: PreviewProvider {
    @State static var previewText: String = ""

    static var previews: some View {
        CustomTextFieldView(
            text: $previewText,
            placeholder: "Preview Placeholder",
            horizontalPadding: 20,
            verticalPadding: 15,
            cornerRadius: 999,
            backgroundColor: .clear,
            borderColor: .gray
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

