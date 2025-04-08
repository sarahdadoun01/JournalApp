//
//  ImagePickerCoordinator.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-01.
//

import SwiftUI
import UIKit

struct ImagePickerCoordinator: UIViewControllerRepresentable {
    static var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var onComplete: ([UIImage]) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(onComplete: onComplete)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = Self.sourceType
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onComplete: ([UIImage]) -> Void

        init(onComplete: @escaping ([UIImage]) -> Void) {
            self.onComplete = onComplete
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                onComplete([image])
            } else {
                onComplete([])
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onComplete([])
        }
    }
}



struct ImagePickerCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        Text("Image Picker") // Placeholder preview
    }
}
