//
//  MarkdownTextView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-01.
//

import SwiftUI
import Foundation

struct MarkdownTextView: UIViewRepresentable {
    @Binding var text: String
    var renderMarkdown: Bool = false

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.delegate = context.coordinator

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.widthTracksTextView = true
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40)
        ])

        return textView
    }


    func updateUIView(_ uiView: UITextView, context: Context) {
        if renderMarkdown {
            if let styled = try? AttributedString(markdown: text) {
                uiView.attributedText = NSAttributedString(styled)
            } else {
                uiView.text = text
            }
        } else {
            if uiView.text != text {
                uiView.text = text
            }
        }
        
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
    }
}

struct MarkdownTextView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownTextView(text: .constant("**Bold** _Italic_ `Code`"))
            .frame(height: 200)
            .padding()
    }
}
