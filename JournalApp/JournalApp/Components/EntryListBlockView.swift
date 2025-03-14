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
        
        GeometryReader { geometry in
            
            HStack(alignment: .center, spacing: 15){
                
                // date of entry ( left side )
                VStack(alignment: .center){
                    Text(formatDate(entry.date, format: "dd")) // day only
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(formatDate(entry.date, format: "MMM")) // ex: Mar
                        .font(.caption)
                        .foregroundColor(.black)
                }.frame(maxWidth: 50)
                
                // entry preview ( right side )
                VStack(alignment: .leading, spacing: 15){
                    
                    // moods
                    if !entry.moods.isEmpty {
                        HStack{
                            ForEach(entry.moods.prefix(2), id: \.self) {
                                mood in Text(mood)
                                    .font(.headline)
                            }
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
                        GeometryReader { geometry in
                            let totalImageWidth = CGFloat(media.count) * 90 // calculate length of media row

                            if totalImageWidth > geometry.size.width {
                                // Use horizontal ScrollView if length if longer than block width
                                ScrollView(.horizontal, showsIndicators: false) {
                                    imageRow(media: media, geometry: geometry)
                                }
                            } else {
                                // Use simple HStack if images fit
                                imageRow(media: media, geometry: geometry)
                            }
                        }
                        .frame(height: 80)
                    }


                }
                .frame(width: geometry.size.width * 0.75, alignment: .leading)
                
            }
            .padding()
            .frame(minHeight: entry.mediaFiles?.isEmpty == false ? 250 : 150)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
            )
            
        }
        .frame(height: entry.mediaFiles?.isEmpty == false ? 250 : 150)
    }
    
    // Function to display images in a row, with or without a ScrollView
    func imageRow(media: [String], geometry: GeometryProxy) -> some View {
        let totalImageWidth = CGFloat(media.count) * 90 // Approx. width of each image + spacing

        return Group {
            if totalImageWidth > geometry.size.width {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(media, id: \.self) { mediaItem in
                            imageView(for: mediaItem)
                        }
                    }
                    .padding(.horizontal, 5)
                }
            } else {
                HStack {
                    ForEach(media, id: \.self) { mediaItem in
                        imageView(for: mediaItem)
                    }
                }
            }
        }
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // Function to display a single image (either from Firebase or from local asset)
    func imageView(for mediaItem: String) -> some View {
        Group {
            if mediaItem.hasPrefix("http") { // Firebase Image (URL)
                AsyncImage(url: URL(string: mediaItem)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        ProgressView()
                    }
                }
            } else { // Local Asset Image
                Image(mediaItem)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 80, height: 80) // Set consistent size
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}



private func formatDate(_ date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}



struct EntryListBlockView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
            // Sample data
            EntryListBlockView(entry: Entry(
                id: "1",
                journalID: "work",
                userID: "testuser@example.com",
                title: "Meeting Notes",
                content: "Had a great meeting today about the new project...",
                date: Date(),
                moods: ["😊", "🚀"],
                mediaFiles: [
                    "sample-image", "sample-image", "sample-image", "sample-image", "sample-image"
                ]
            ))
                    
            EntryListBlockView(entry: Entry(
                id: "2",
                journalID: "work",
                userID: "testuser@example.com",
                title: "Daily Reflection",
                content: "Today was a good day. I accomplished a lot and stayed productive!",
                date: Date(),
                moods: ["😌", "🌟"]
            ))
            
            EntryListBlockView(entry: Entry(
                id: "2",
                journalID: "personal",
                userID: "testuser@example.com",
                title: "Relaxing Weekend",
                content: "Spent time at the beach and read a book",
                date: Date(),
                moods: ["😌", "🌟"]
            ))
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
