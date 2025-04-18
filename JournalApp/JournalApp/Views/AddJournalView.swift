//
//  AddJournalView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-29.
//

import SwiftUI

struct AddJournalView: View {
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

    var userID: String
    var onAddComplete: () -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Title Input
                CustomTextFieldView(
                    text: $title,
                    placeholder: "Journal Title",
                    autocapitalization: .words,
                    horizontalPadding: 20,
                    verticalPadding: 15,
                    cornerRadius: 999,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#B9B9B9"),
                    textColor: .primary,
                    font: .body,
                    onTextChange: { _ in
                        if selectedColor == nil {
                            selectedColor = presetColors.randomElement()
                        }
                    }
                )


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
                    }.padding(.vertical, 5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.leading, 5)
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
                    Button("Save") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty, let color = selectedColor else { return }

                        let uiColor = UIColor(selectedColor ?? .gray)
                        let hex = uiColor.hexString ?? "#999999"

                        FirebaseService.shared.createJournal(userID: userID, title: title, colorHex: hex) { success in
                            if success {
                                onAddComplete()
                                dismiss()
                            }
                        }
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

class ColorPickerDelegate: NSObject, UIColorPickerViewControllerDelegate {
    var didSelectColor: ((Color) -> Void)

    init(_ didSelectColor: @escaping ((Color) -> Void)) {
        self.didSelectColor = didSelectColor
    }

    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        didSelectColor(Color(uiColor: viewController.selectedColor))
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        print("Dismissed color picker")
    }
}

struct ColorPickerView: UIViewControllerRepresentable {
    private let delegate: ColorPickerDelegate
    private let pickerTitle: String
    private let selectedColor: UIColor

    init(title: String, selectedColor: Color, didSelectColor: @escaping ((Color) -> Void)) {
        self.pickerTitle = title
        self.selectedColor = UIColor(selectedColor)
        self.delegate = ColorPickerDelegate(didSelectColor)
    }

    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let controller = UIColorPickerViewController()
        controller.delegate = delegate
        controller.title = pickerTitle
        controller.selectedColor = selectedColor
        return controller
    }

    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {}
}

extension UIColor {
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

struct AddJournalView_Previews: PreviewProvider {
    static var previews: some View {
        AddJournalView(userID: "previewUser", onAddComplete: {})
    }
}
