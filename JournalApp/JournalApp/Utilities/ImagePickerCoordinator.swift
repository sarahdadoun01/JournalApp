//
//  ImagePickerCoordinator.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-01.
//

import SwiftUI
import PhotosUI

struct ImagePickerCoordinator: UIViewControllerRepresentable {
    var onComplete: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0 // allow multiple
        config.filter = .any(of: [.images, .videos])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onComplete: ([UIImage]) -> Void

        init(onComplete: @escaping ([UIImage]) -> Void) {
            self.onComplete = onComplete
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            let itemProviders = results.map(\.itemProvider)
            var images: [UIImage] = []

            let group = DispatchGroup()

            for provider in itemProviders {
                if provider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    provider.loadObject(ofClass: UIImage.self) { object, _ in
                        if let image = object as? UIImage {
                            images.append(image)
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.onComplete(images)
            }
        }
    }
}


struct ImagePickerCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        Text("Image Picker") // Placeholder preview
    }
}
