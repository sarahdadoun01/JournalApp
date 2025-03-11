//
//  AddEntryView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-27.
//

import SwiftUI

struct AddEntryView: View {
    @State private var entryText: String = ""
    @State private var selectedMoods: [String] = []
    @EnvironmentObject var firebaseService: FirebaseService // ✅ Now works!
    @Environment(\.presentationMode) var presentationMode
    var selectedJournalID: String

    var body: some View {
        VStack {
            // Mood Section
            if !selectedMoods.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedMoods, id: \.self) { mood in
                            Text(mood)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            TextEditor(text: $entryText)
                .padding()
                .frame(maxHeight: .infinity)

           // ToolbarView(selectedMoods: $selectedMoods)

            // Save Button
            Button(action: saveEntry) {
                Text("Save Entry")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }

    private func saveEntry() {
        guard !entryText.isEmpty else { return }

        firebaseService.saveEntry(
            journalID: selectedJournalID,
            userID: "test_user", // Replace with actual user ID
            title: "New Entry",
            content: entryText,
            moods: selectedMoods
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

