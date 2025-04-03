//
//  AddTagView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-02.
//

import SwiftUI

struct AddTagView: View {
    @Environment(\.dismiss) var dismiss

    @State private var tagName: String = ""

    var userID: String
    var onAddComplete: () -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                CustomTextFieldView(
                    text: $tagName,
                    placeholder: "Tag name",
                    autocapitalization: .never,
                    horizontalPadding: 20,
                    verticalPadding: 15,
                    cornerRadius: 999,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#B9B9B9"),
                    textColor: .primary,
                    font: .body,
                    onTextChange: { _ in }
                )

                Spacer()
            }
            .padding()
            .navigationTitle("Add Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }

                        FirebaseService.shared.createTag(userID: userID, name: trimmed) { success in
                            if success {
                                onAddComplete()
                                dismiss()
                            }
                        }
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct AddTagView_Previews: PreviewProvider {
    static var previews: some View {
        AddTagView(userID: "previewUser", onAddComplete: {})
    }
}
