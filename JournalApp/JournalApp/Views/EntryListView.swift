//
//  EntryListView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-27.
//

import SwiftUI

struct EntryListView: View {
    var journalID: String

    var body: some View {
        Text("Entries for Journal: \(journalID)")
    }
}


struct EntryListView_Previews: PreviewProvider {
    static var previews: some View {
        EntryListView(journalID: "sampleJournalID") // ✅ Pass a sample journal ID
    }
}
