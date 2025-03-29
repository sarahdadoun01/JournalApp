//
//  AddJournalView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-29.
//

import SwiftUI

struct AddTagView: View {
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var selectedColor: Color? = nil
    @State private var customColor: Color = .gray {
        didSet {
            // Update selected color and close the picker when changed
            selectedColor = customColor
            showColorPicker = false
        }
    }
    @State private var showColorPicker: Bool = false

    let presetColors: [Color] = [.orange, .yellow, .red, .blue, .green]

    var onSave: (_ title: String, _ color: Color) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title Input
                TextField("Journal Title", text: $title)
                    .autocapitalization(.words)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .onChange(of: title) { _ in
                        if selectedColor == nil {
                            selectedColor = presetColors.randomElement()
                        }
                    }

                // Color Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Journal Color")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    HStack(spacing: 12) {
                        ForEach(presetColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                        .shadow(radius: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                    showColorPicker = false
                                }
                        }

                        // Rainbow circle to trigger custom color picker sheet
                        Button(action: {
                            showColorPicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .strokeBorder(
                                        AngularGradient(
                                            gradient: Gradient(colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red]),
                                            center: .center
                                        ),
                                        lineWidth: 3
                                    )
                                    .frame(width: 36, height: 36)

                                Circle()
                                    .fill(customColor)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: selectedColor == customColor ? 3 : 0)
                                    )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $showColorPicker) {
                            ColorPickerView(
                                title: "Pick a Color",
                                selectedColor: customColor,
                                didSelectColor: { color in
                                    self.customColor = color
                                }
                            )
                            .presentationDetents([.height(500)])
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("Add Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty, let color = selectedColor else { return }
                        onSave(title, color)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || selectedColor == nil)
                }
            }
        }
        .onAppear {
            if selectedColor == nil {
                selectedColor = presetColors.randomElement()
            }
        }
    }
}

struct AddTagView_Previews: PreviewProvider {
    static var previews: some View {
        AddJournalView(onSave: { _, _ in })
    }
}

