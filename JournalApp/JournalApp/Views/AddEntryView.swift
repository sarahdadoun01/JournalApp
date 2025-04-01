//
//  AddEntryView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
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
    case video
    case audio
}

struct AddEntryView: View {
    @Binding var journals: [Journal]

    @State private var entryTitle: String = "Untitled"
    @State private var selectedMoods: [String] = []
    @State private var selectedTags: [String] = []
    @State private var blocks: [EntryBlock] = [EntryBlock(type: .text, content: "")]
    @State private var selectedMediaFiles: [UIImage] = []
    @State private var isKeyboardVisible = false
    @State private var hasEditedTitle = false
    @State private var showMoodPicker = false
    @State private var selectedJournalTitle: String = ""
    @State var selectedJournalID: String?

    var onSaveComplete: () -> Void = {}

    @Environment(\.presentationMode) var presentationMode

    @StateObject private var firebaseService = FirebaseService()
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {
            // 🔝 Top Purple Header
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack(alignment: .leading) {
                            if entryTitle.isEmpty {
                                Text("Title")
                                    .foregroundColor(.white.opacity(0.4))
                                    .font(.title)
                                    .padding(.leading, 4)
                            }

                            TextField("", text: $entryTitle)
                                .font(.title)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .focused($isTextFieldFocused)
                                .tint(.white)
                                .onChange(of: isTextFieldFocused) { focused in
                                    if focused && entryTitle == "Untitled" && !hasEditedTitle {
                                        entryTitle = ""
                                        hasEditedTitle = true
                                    }
                                }
                        }

                        Text(formatCurrentDate())
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    CircularIconButtonView(
                        systemName: "checkmark",
                        size: 48,
                        padding: 15,
                        backgroundColor: .clear,
                        borderColor: .white,
                        iconColor: .white
                    ) {
                        saveEntry()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(Color.purple)

            EntryContentView(
                mainText: $blocks[0].content,
                selectedTags: $selectedTags,
                selectedMoods: $selectedMoods,
                selectedMediaFiles: $selectedMediaFiles,
                selectedJournal: $selectedJournalID,
                blocks: $blocks
            )
            .onAppear {
                showKeyboard()
            }
            .refreshable {
                if shouldSaveEntry() {
                    await saveEntryAsync()
                }
            }

            // ⌨️ Toolbar
            if isKeyboardVisible {
                FloatingToolbarMenuView(
                    onAddMood: addMood,
                    onAddText: addText,
                    onAddImage: addImage,
                    onAddVoiceMemo: addVoiceMemo,
                    onAddTag: addTag,
                    onSelectJournal: selectJournal,
                    showMoodPicker: $showMoodPicker
                )
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.3), value: isKeyboardVisible)
            }
        }
        .onAppear {
            if let journal = journals.first(where: { $0.id == selectedJournalID }) {
                selectedJournalTitle = journal.title
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
            observeKeyboardNotifications()
        }
        .sheet(isPresented: $showMoodPicker) {
            SelectMoodsView(
                selectedMoods: $selectedMoods,
                availableMoods: Mood.all
            )
        }
    }

    private func formatCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy - h:mm a"
        return formatter.string(from: Date())
    }

    private func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIApplication.shared.sendAction(
                #selector(UIResponder.becomeFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }

    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            isKeyboardVisible = true
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            isKeyboardVisible = false
        }
    }

    private func addMood() {
        print("Mood added")
    }

    private func addText() {
        withAnimation {
            blocks.append(EntryBlock(type: .text, content: ""))
        }
    }

    private func addImage() {
        print("Image added")
    }

    private func addVoiceMemo() {
        print("Voice memo added")
    }

    private func addTag() {
        print("Tag added")
    }

    private func selectJournal() {
        print("Journal selected")
    }

    private func saveEntry(completion: (() -> Void)? = nil) {
        let textBlocks = blocks.filter { $0.type == .text }.map { $0.content }.joined(separator: "\n\n")

        guard !entryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !textBlocks.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !selectedMediaFiles.isEmpty else {
            presentationMode.wrappedValue.dismiss()
            return
        }

        if selectedMediaFiles.isEmpty {
            saveEntryWithMedia(mediaURLs: [])
            completion?()
        } else {
            uploadMediaFiles { uploadedURLs in
                saveEntryWithMedia(mediaURLs: uploadedURLs)
                completion?()
            }
        }
    }

    @MainActor
    private func saveEntryAsync() async {
        let textBlocks = blocks.filter { $0.type == .text }.map { $0.content }.joined(separator: "\n\n")

        guard !entryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !textBlocks.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !selectedMediaFiles.isEmpty else {
            presentationMode.wrappedValue.dismiss()
            return
        }

        let mediaURLs: [String]
        if selectedMediaFiles.isEmpty {
            mediaURLs = []
        } else {
            mediaURLs = await uploadMediaFilesAsync()
        }

        saveEntryWithMedia(mediaURLs: mediaURLs)
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

    private func uploadMediaFilesAsync() async -> [String] {
        var uploadedURLs: [String] = []

        await withTaskGroup(of: String?.self) { group in
            for image in selectedMediaFiles {
                group.addTask {
                    return await firebaseService.uploadImage(image: image)
                }
            }

            for await result in group {
                if let url = result {
                    uploadedURLs.append(url)
                }
            }
        }

        return uploadedURLs
    }

    private func saveEntryWithMedia(mediaURLs: [String]) {
        let textBlocks = blocks.filter { $0.type == .text }.map { $0.content }.joined(separator: "\n\n")

        guard let user = Auth.auth().currentUser else {
            print("Error: No authenticated user identified.")
            return
        }

        firebaseService.saveEntry(
            journalID: selectedJournalID!.lowercased(),
            userID: user.uid,
            title: entryTitle,
            content: textBlocks,
            moods: selectedMoods,
            mediaFiles: mediaURLs,
            tags: selectedTags
        ) { success in
            if success {
                onSaveComplete()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func shouldSaveEntry() -> Bool {
        let textBlocks = blocks
            .filter { $0.type == .text }
            .map { $0.content }
            .joined(separator: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let titleIsValid = !entryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let contentIsValid = !textBlocks.isEmpty

        return titleIsValid || contentIsValid
    }
}


struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryView(
            journals:  .constant([
                Journal(id: "1", userID: "user1", title: "Personal", createdAt: Date()),
                Journal(id: "2", userID: "user1", title: "Work", createdAt: Date())
            ]),
            selectedJournalID: "All",
            onSaveComplete: {}
        )
    }
}
