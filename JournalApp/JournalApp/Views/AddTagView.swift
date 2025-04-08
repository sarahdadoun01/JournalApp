//
//  AddTagView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-02.
//

import SwiftUI

struct AddTagView: View {
    @Environment(\.dismiss) var dismiss

    var userID: String
    var onAddComplete: () -> Void

    @State private var tagName: String = ""
    @State private var selectedColor: Color = Color(hex: "#9C27B0")

    // Optional: a palette of predefined colors like in AddJournalView
    private let presetColors: [Color] = [
        Color(hex: "#9C27B0"),
        Color(hex: "#FF9800"),
        Color(hex: "#03A9F4"),
        Color(hex: "#4CAF50"),
        Color(hex: "#F44336")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add New Tag")
                .font(.title2)
                .fontWeight(.semibold)

            CustomTextFieldView(
                text: $tagName,
                placeholder: "Tag name",
                autocapitalization: .words,
                horizontalPadding: 20,
                verticalPadding: 15,
                cornerRadius: 12,
                backgroundColor: .clear,
                borderColor: Color(hex: "#B9B9B9"),
                textColor: .primary,
                font: .body,
                onTextChange: { _ in }
            )

            Text("Choose a color")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(presetColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(selectedColor == color ? 1 : 0), lineWidth: 2)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }

                ColorPicker("", selection: $selectedColor)
                    .labelsHidden()
            }

            Spacer()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)

                Spacer()

                Button("Save") {
                    let trimmed = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }

                    let uiColor = UIColor(selectedColor ?? .gray)
                    let hex = uiColor.hexString ?? "#999999"

                    FirebaseService.shared.createTag(userID: userID, name: trimmed, colorHex: hex) { success in
                        if success {
                            onAddComplete()
                            dismiss()
                        }
                    }
                }
                .disabled(tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.top, 20)
        }
        .padding()
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }
}

struct AddTagView_Previews: PreviewProvider {
    static var previews: some View {
        AddTagView(userID: "preview", onAddComplete: {})
    }
}
