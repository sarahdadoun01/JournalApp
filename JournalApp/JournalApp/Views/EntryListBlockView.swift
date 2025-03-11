//
//  EntryListBlockView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

import SwiftUI

struct EntryListBlockView: View {
    
    var entry: Entry
    @State private var entries: [Entry] = []
    @StateObject private var firebaseService = FirebaseService()
    
    var body: some View {
        HStack(alignment: .center, spacing: 15){
            
            // date of entry
            VStack(alignment: .center){
                Text(formatDate(entry.date, format: "dd")) // day only
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(formatDate(entry.date, format: "MMM")) // ex: Mar
                    .font(.caption)
                    .foregroundColor(.black)
            }.frame(width: 50)
            
            // entry preview
            VStack(alignment: .leading, spacing: 6){
                    
                    // moods
                    if !entry.moods.isEmpty {
                        HStack{
                            Text("Mood icons go here")
                        }
                    }
                    
                    // title
                    
                    if !entry.title.isEmpty {
                        HStack{
                            Text(entry.title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .lineLimit(1)
                        }
                    }
                    
                    // content
                    HStack{
                        Text(entry.content)
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .lineLimit(2)
                    }
                    
                    // media
                    if let media = entry.mediaFiles, !media.isEmpty {
                        HStack{
                            Text("Photos go here")
                        }
                    }
            }
            
        }.padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 10))
    }
}

private func formatDate(_ date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}

struct EntryListBlockView_Previews: PreviewProvider {
    static var previews: some View {
        EntryListBlockView(entry: Entry(
            id: "1",
            journalID: "work",
            userID: "testuser@example.com",
            title: "Meeting Notes",
            content: "Had a great meeting today about the new project...",
            date: Date(),
            moods: ["😊", "🚀"]
        ))
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
