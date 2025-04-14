//
//  RenameAlertView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-12.
//

import SwiftUI
import UIKit

struct RenameAlertView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var currentTitle: String
    var onSave: (String) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented else { return }

        let alert = UIAlertController(
            title: "Rename Recording",
            message: "Enter a new name",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "New name"
            textField.text = currentTitle
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            isPresented = false
        })

        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let newName = alert.textFields?.first?.text {
                onSave(newName)
            }
            isPresented = false
        })

        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true)
        }
    }
}


extension View {
    func renameAlertView(
        isPresented: Binding<Bool>,
        currentTitle: String,
        onSave: @escaping (String) -> Void
    ) -> some View {
        self.background(
            RenameAlertView(
                isPresented: isPresented,
                currentTitle: currentTitle,
                onSave: onSave
            )
            .frame(width: 0, height: 0) // hidden
        )
    }
}
