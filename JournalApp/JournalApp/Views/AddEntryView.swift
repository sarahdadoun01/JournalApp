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

struct EntryBlock: Identifiable {
    var id = UUID()
    var type: BlockType
    var content: String
}

enum BlockType {
    case text
    case image
}

struct AddEntryView: View {
    @State private var entryTitle: String = "Untitled"
    @State private var selectedMoods: [String] = []
    @State private var selectedTags: [String] = []
    @State private var blocks: [EntryBlock] = [EntryBlock(type: .text, content: "")]
    @State private var selectedMediaFiles: [UIImage] = []
    @State private var isKeyboardVisible = false

    @Environment(\.presentationMode) var presentationMode
    let selectedJournalID: String
    
    @StateObject private var firebaseService = FirebaseService()
    
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {
            
            /// TOP
            VStack{
                
                HStack{
                    VStack(alignment: .leading) { // Align content to the right
                        // Title Field
                        TextField("Title", text: $entryTitle)
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading) // Align text to the right
                            //.focused($isTextFieldFocused) // automatically focus on title

                        Text("\(formatCurrentDate())")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    VStack(alignment: .center){
                        Button(action: saveEntry) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white) // White checkmark
                                    .font(.system(size: 17, weight: .bold))
                                    .frame(width: 40, height: 40) // size of the button
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.2))
                                    )
                            }
                    }.frame(width: 50, height: 57,alignment: .trailing)
                    
                }.padding(.horizontal,20)
                .padding(.vertical,20)
                
            }.background(Color.blue)
            
            
            
            /// CONTENT
            // Mood Selection
            HStack {
                ForEach(selectedMoods, id: \.self) { mood in
                    Text(mood)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

//            // Entry Blocks (Text, Images, etc.)
//            ScrollView {
//                VStack {
//                    ForEach($blocks) { $block in
//                        if block.type == .text {
//                            TextEditor(text: $block.content)
//                                .frame(minHeight: 40)
//                                .padding()
//                                .background(.white)
//                                .cornerRadius(15)
//                                .focused($isTextFieldFocused)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }.background(.gray)
            
            // Entry Blocks (Text, Images, etc.)
            Form {
                ForEach($blocks) { $block in
                    if block.type == .text {
                        TextEditor(text: $block.content)
                            .frame(minHeight: 40)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .focused($isTextFieldFocused)
                    }
                }
            }
            .onAppear {
                showKeyboard() // Force keyboard to appear
            }

            // Floating Toolbar
            if isKeyboardVisible {
                FloatingToolbarMenuView(
                    onAddMood: addMood,
                    onAddText: addText,
                    onAddImage: addImage,
                    onAddVoiceMemo: addVoiceMemo,
                    onAddTag: addTag,
                    onSelectJournal: selectJournal
                )

                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3))
            }
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
            observeKeyboardNotifications()
        }

        
    }
    
    private func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIApplication.shared.sendAction(
                #selector(UIResponder.becomeFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
    
    // Date Formatter
    private func formatCurrentDate() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy - h:mm a"
        return formatter.string(from:Date())
    }
    
    private func addMood() {
        print("Mood added")
        // Add logic to insert mood into entry
    }

    private func addText() {
        withAnimation {
            blocks.append(EntryBlock(type: .text, content: ""))
        }
    }

    private func addImage() {
        print("Image added")
        // Add logic to open image picker and insert image
    }

    private func addVoiceMemo() {
        print("Voice memo added")
        // Add logic for voice memo recording
    }

    private func addTag() {
        print("Tag added")
        // Add logic for adding tags
    }

    private func selectJournal() {
        print("Journal selected")
        // Add logic for journal selection
    }


    // MARK: - Floating Toolbar Handlers
    private func addBlock(_ type: BlockType) {
        withAnimation {
            blocks.append(EntryBlock(type: type, content: ""))
        }
    }

    // MARK: - Keyboard Observers
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            isKeyboardVisible = true
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            isKeyboardVisible = false
        }
    }

    // MARK: - Save Entry Logic
    private func saveEntry() {
        // Check if there is no meaningful content
        let textBlocks = blocks.filter { $0.type == .text }.map { $0.content }.joined(separator: "\n\n")

        guard !entryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !textBlocks.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !selectedMediaFiles.isEmpty else {
            // No meaningful content → Just exit without saving
            presentationMode.wrappedValue.dismiss()
            return
        }

        if selectedMediaFiles.isEmpty {
            saveEntryWithMedia(mediaURLs: [])
        } else {
            uploadMediaFiles { uploadedURLs in
                saveEntryWithMedia(mediaURLs: uploadedURLs)
            }
        }
    }


    private func uploadMediaFiles(completion: @escaping ([String]) -> Void) {
        let uploadedURLs = UploadedURLs()
        let dispatchGroup = DispatchGroup()

        for image in selectedMediaFiles {
            dispatchGroup.enter()
            Task {
                let url = await firebaseService.uploadImage(image: image)
                if let url = url {
                    await uploadedURLs.append(url)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            Task {
                let urls = await uploadedURLs.getURLs()
                completion(urls)
            }
        }
    }

    private func saveEntryWithMedia(mediaURLs: [String]) {
        let textBlocks = blocks.filter { $0.type == .text }.map { $0.content }.joined(separator: "\n\n")

        firebaseService.saveEntry(
            journalID: selectedJournalID,
            userID: "test_user",
            title: entryTitle,
            content: textBlocks,
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
