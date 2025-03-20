//
//  AddEntryView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-27.
//

import SwiftUI
import Firebase

actor UploadedURLs {
    var urls: [String] = []

    func append(_ url: String) {
        urls.append(url)
    }

    func getURLs() -> [String] {
        return urls
    }
}

struct AddEntryView: View {
    @State private var entryText: String = ""
    @State private var entryTitle: String = ""
    @State private var selectedMoods: [String] = []
    @State private var selectedTags: [String] = []
    //@State private var blocks: [EntryBlock] = []
    @State private var isKeyboardVisible = false
    @State private var selectedMediaFiles: [UIImage] = [] // ✅ Store selected images
    
    @Environment(\.presentationMode) var presentationMode
    let selectedJournalID: String
    
    @StateObject private var firebaseService = FirebaseService()
    
    var body: some View {
        VStack {
            // Moods
            HStack {
                ForEach(selectedMoods, id: \.self) { mood in
                    Text(mood)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
            }.padding(.horizontal)

            // Text Editor for Entry Content
            TextEditor(text: $entryText)
                .padding()
                .frame(maxHeight: .infinity)

            // Media Upload Button
            Button(action: {
                pickMedia()
            }) {
                Text("Add Media")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }.padding()

            // Display Selected Media
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(selectedMediaFiles, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }.padding()

            // Save Button
            Button(action: saveEntry) {
                Text("Save Entry")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }.padding()
        }
    }

    
    // ✅ Media Picker Function
    private func pickMedia() {
        // Implement a way to select images (Using PHPickerViewController or UIImagePickerController)
    }
    
    // ✅ Upload Media, then Save Entry
    private func saveEntry() {
        guard !entryText.isEmpty else { return }
        
        if selectedMediaFiles.isEmpty {
            // If no media, save entry immediately
            saveEntryWithMedia(mediaURLs: [])
        } else {
            uploadMediaFiles { uploadedURLs in
                saveEntryWithMedia(mediaURLs: uploadedURLs)
            }
        }
    }


    private func uploadMediaFiles(completion: @escaping ([String]) -> Void) {
        let uploadedURLs = UploadedURLs() // ✅ Correct variable name
        let dispatchGroup = DispatchGroup()

        for image in selectedMediaFiles {
            dispatchGroup.enter()

            Task {
                let url = await firebaseService.uploadImage(image: image)

                if let url = url {
                    await uploadedURLs.append(url) // ✅ Corrected reference
                }

                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            Task {
                let urls = await uploadedURLs.getURLs() // ✅ Corrected reference
                completion(urls)
            }
        }
    }




    
    // ✅ Save Entry with Uploaded Media URLs
    private func saveEntryWithMedia(mediaURLs: [String]) {
        firebaseService.saveEntry(
            journalID: selectedJournalID,
            userID: "test_user",
            title: "New Entry",
            content: entryText,
            moods: selectedMoods,
            mediaFiles: mediaURLs,
            tags: selectedTags
        ) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryView(selectedJournalID: "sampleJournalID")
    }
}

