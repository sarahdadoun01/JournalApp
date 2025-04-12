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

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0 // 0 = unlimited selection
        config.filter = .any(of: [.images])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerCoordinator

        init(_ parent: ImagePickerCoordinator) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            print("📸 Final image count returned from ImagePickerCoordinator: \(results.count)")
            print("📸 Picker returned \(results.count) result(s)")

            for (i, result) in results.enumerated() {
                print("📦 Result \(i): canLoad UIImage? \(result.itemProvider.canLoadObject(ofClass: UIImage.self))")
            }


            var uiImages: [(Int, UIImage)] = []
            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue(label: "com.journalApp.imageLoadingQueue")

            for (index, result) in results.enumerated() {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    dispatchGroup.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        if let image = object as? UIImage {
                            queue.async {
                                uiImages.append((index, image))
                                dispatchGroup.leave()
                            }
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                let sortedImages = uiImages.sorted { $0.0 < $1.0 }.map { $0.1 }
                print("✅ Final image count returned from ImagePickerCoordinator: \(sortedImages.count)")
                for (index, image) in sortedImages.enumerated() {
                    print("🖼️ Image \(index): \(image.size)")
                }
                self.parent.onComplete(sortedImages)
                picker.dismiss(animated: true)
            }
        }
    }
}



struct ImagePickerCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        Text("Image Picker") // Placeholder preview
    }
}
