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
    @State private var selectedJournalTitle: String = ""
    @State var selectedJournalID: String?
    @State private var showTextFormatMenu = false
    @State private var showMediaMenu = false
    @State private var activeSheet: ActiveSheet?
    @State private var showFormattedText = false
    @State private var showAddTagSheet = false
    @State private var isChildTextEditorFocused = false
    @State private var activeInlinePopup: InlinePopupType? = nil
    @State private var activeModalSheet: ActiveSheet? = nil
    @State private var moodButtonFrame: CGRect = .zero
    @State private var formatButtonFrame: CGRect = .zero
    @State private var userTags: [String] = []
    @State private var selectedTab = 0
    @State private var entryID: String? = UUID().uuidString
    @State private var uploadedTempMediaURLs: [String] = [] // track unsaved entries to clean up storage
    @State private var entryWasSaved: Bool = false
    @State private var showInlineJournalPicker = false
    @State private var isRecordingAudio = false
    @State private var currentRecordingURL: URL?

    
    @FocusState private var isTitleFocused: Bool

    var onSaveComplete: () -> Void = {}
    var onTagAdded: () -> Void = {}

    @Environment(\.presentationMode) var presentationMode

    @StateObject private var firebaseService = FirebaseService()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                VStack(spacing: 0) {
                    // -- Title & Save Button --
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
                                        .focused($isTitleFocused)
                                        .tint(.white)
                                        .onChange(of: isTitleFocused) { focused in
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

                    // Entry Content
                    EntryContentView(
                        mainText: $blocks[0].content,
                        selectedTags: $selectedTags,
                        selectedMoods: $selectedMoods,
                        selectedMediaFiles: $selectedMediaFiles,
                        selectedJournalID: $selectedJournalID,
                        blocks: $blocks,
                        renderMarkdown: $showFormattedText,
                        journals: $journals,
                        isTextEditorFocused: $isChildTextEditorFocused,
                        selectedTab: $selectedTab,
                        entryID: $entryID,
                        showAddTagSheet: $showAddTagSheet,
                        userTags: $userTags,
                        showInlineJournalPicker: $showInlineJournalPicker
                    )
                    .onAppear { showKeyboard() }
                    .refreshable {
                        if shouldSaveEntry() {
                            await saveEntryAsync()
                        }
                    }

                    if showTextFormatMenu {
                        TextFormattingToolbarView(onFormat: applyFormat)
                    }

                    // Show floating toolbar if the keyboard is up
                    if isKeyboardVisible {
                        FloatingToolbarMenuView(
                            onAddMood: {
                                showTextFormatMenu = false
                                togglePopup(for: .moodPicker)
                            },
                            onAddText: {
                                activeSheet = nil
                                showTextFormatMenu.toggle()
                            },
                            onAddImage: {
                                activeModalSheet = .imagePicker
                            },
                            onTakePhoto: {
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    activeModalSheet = .imagePicker
                                } else {
                                    print("🚫 Camera not available on this device")
                                }
                            },
                            onAddVoiceMemo: addVoiceMemo,
                            onAddTag: { tag in
                                // if it doesnt already contain it, add it
                                if !selectedTags.contains(tag) {
                                    selectedTags.append(tag)
                                }
                            },
                            onSelectJournal: {
                                showTextFormatMenu = false
                                togglePopup(for: .journalPicker)
                            },
                            selectedJournalID: $selectedJournalID,
                            selectedTags: $selectedTags,
                            moodButtonFrame: $moodButtonFrame,
                            formatButtonFrame: $formatButtonFrame,
                            activeInlinePopup: $activeInlinePopup,
                            showAddTagSheet: $showAddTagSheet,
                            userTags: $userTags,
                            journals: journals
                        )
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut(duration: 0.3), value: isKeyboardVisible)
                    }
                }
                
                // Mood button
                if activeInlinePopup == .moodPicker {
                    GeometryReader { geo in
                        ZStack {
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    withAnimation {
                                        activeInlinePopup = nil
                                    }
                                }

                            SelectMoodsView(
                                selectedMoods: $selectedMoods,
                                availableMoods: Mood.all
                            )
                            .position(x: formatButtonFrame.midX + 20, y: formatButtonFrame.minY - 120)
                            //.position(x: safeX, y: safeY)
                            .transition(.move(edge: .bottom))
                            .zIndex(10)
                        }
                    }
                    .animation(.easeInOut, value: activeInlinePopup)
                }
                
                
                // Format Button
                if activeInlinePopup == .formattingToolbar {
                    GeometryReader { geo in
                        ZStack {
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    withAnimation {
                                        activeInlinePopup = nil
                                    }
                                }
                            let xOffset: CGFloat = 80
                            let yOffset: CGFloat = -75

                            TextFormattingToolbarView(onFormat: applyFormat)
                                .position(x: formatButtonFrame.midX + xOffset,
                                          y: formatButtonFrame.minY + yOffset)
                                .transition(.move(edge: .bottom))
                                .zIndex(10)
                        }
                    }
                    .animation(.easeInOut, value: activeInlinePopup)
                    
                }


            }
            .sheet(item: $activeModalSheet) { sheet in
                switch sheet {
                case .mediaViewer:
                    MediaPreviewView(mediaItems: selectedMediaFiles)
                case .voiceRecorder:
                    Text("Voice Recorder View")
                case .imagePicker:
                    ImagePickerCoordinator { images in
                        
                        //DEBUG
                        print("🌈 Images returned from picker: \(images.count)")
                        for (i, img) in images.enumerated() {
                            print("🖼️ Image \(i) size: \(img.size)")
                        }
                        
                        Task {
                            var urls: [String] = []
                            

                            await withTaskGroup(of: String?.self) { group in
                                for image in images {
                                    group.addTask {
                                        return await firebaseService.uploadImage(image: image)
                                    }
                                }

                                for await result in group {
                                    if let url = result {
                                        urls.append(url)
                                    }
                                }
                            }

                            // Append all at once
                            for url in urls {
                                uploadedTempMediaURLs.append(url)
                                blocks.append(EntryBlock(type: .image, content: url))
                            }

                            selectedTab = 1
                            activeSheet = nil
                        }
                    }
                


                default:
                    EmptyView()
                }
            }
            .sheet(isPresented: $showAddTagSheet) {
                AddTagView(
                    userID: FirebaseService.shared.currentUserID ?? "unknown",
                    onAddComplete: {
                        Task {
                            userTags = try await FirebaseService.shared.fetchUserTagsName()
                            onTagAdded() // refresh tags list in FloatingToolbarView
                        }
                        showAddTagSheet = false
                    }
                )
            }
            .onAppear {
                print("🧩 [AddEntryView] appeared")
                if let journal = journals.first(where: { $0.id == selectedJournalID }) {
                    selectedJournalTitle = journal.title
                }

                Task {
                    userTags = try await FirebaseService.shared.fetchUserTagsName()
                    onTagAdded() // refresh sidebar in HomeView
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTitleFocused = true
                }

                observeKeyboardNotifications()
            }

            .onChange(of: isChildTextEditorFocused) { newValue in
                isKeyboardVisible = newValue
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isKeyboardVisible = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isKeyboardVisible = false
            }
            .onPreferenceChange(MoodButtonFrameKey.self) { frame in
                moodButtonFrame = frame
                print("🟡 Mood button frame: \(frame)")
            }
            .onDisappear {
                if !entryWasSaved {
                    for url in uploadedTempMediaURLs {
                        FirebaseService.shared.deleteImage(at: url)
                    }
                }
            }
            
        }
    }

    private func togglePopup(for popup: InlinePopupType) {
        guard activeInlinePopup != popup else {
            activeInlinePopup = nil
            return
        }

        activeInlinePopup = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            activeInlinePopup = popup
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
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = true
        }
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = false
        }
    }

    private func applyFormat(_ style: TextFormatStyle) {
        guard let index = blocks.firstIndex(where: { $0.type == .text }) else { return }
        let original = blocks[index].content
        blocks[index].content = TextFormatHelper.applyFormat(style, to: original)
    }

    private func addVoiceMemo() {
        print("Voice memo added")
    }

    private func addTag() {
        print("Tag added")
    }

    private func saveEntry(completion: (() -> Void)? = nil) {
        let textBlocks = blocks
            .filter { $0.type == .text }
            .map { $0.content }
            .joined(separator: "\n\n")

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
        let textBlocks = blocks
            .filter { $0.type == .text }
            .map { $0.content }
            .joined(separator: "\n\n")

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

        blocks.removeAll { $0.type == .image }

        for url in uploadedURLs {
            blocks.append(EntryBlock(type: .image, content: url))
        }

        return uploadedURLs
    }


    private func saveEntryWithMedia(mediaURLs: [String]) {
        let textBlocks = blocks
            .filter { $0.type == .text }
            .map { $0.content }
            .joined(separator: "\n\n")

        guard let user = Auth.auth().currentUser else {
            print("Error: No authenticated user identified.")
            return
        }

        firebaseService.saveEntry(
            journalID: selectedJournalID ?? "unknown",
            userID: user.uid,
            title: entryTitle,
            content: textBlocks,
            moods: selectedMoods,
            mediaFiles: mediaURLs,
            tags: selectedTags
        ) { success in
            if success {
                print("✅ Entry saved to Firestore")

                // ✅ Now save all image blocks to Firestore
                for block in blocks where block.type == .image {
                    firebaseService.saveMediafiles(
                        entryID: entryID ?? "unknown",
                        fileURL: block.content,
                        fileType: .image
                    ) { mediaSaved in
                        if mediaSaved {
                            print("✅ Media file saved to Firestore: \(block.content)")
                        } else {
                            print("❌ Failed to save media file: \(block.content)")
                        }
                    }
                }
                
                uploadedTempMediaURLs.removeAll()
                entryWasSaved = true
                onSaveComplete()
                presentationMode.wrappedValue.dismiss()
            } else {
                print("❌ Failed to save entry.")
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
