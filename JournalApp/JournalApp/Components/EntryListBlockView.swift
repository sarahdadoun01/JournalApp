//
//  EntryListBlockView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-11.
//

import SwiftUI

struct EntryListBlockView: View {
    
    var onTap: (() -> Void)? = nil
    var entry: Entry
    @Binding var activeSwipedID: String?
    var onDelete: () -> Void

    @GestureState private var dragOffset: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var isDragging: Bool = false

    var body: some View {
        
        ZStack(alignment: .trailing) {
            // 🔴 Background delete button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 60, height: 60)
                }
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.trailing, 10)
            }

            // ⚪️ Foreground card with drag + tap
            content
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle()) // Ensures whole block is tappable
                .offset(x: offsetX)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            offsetX = value.translation.width < 0 ? value.translation.width : 0
                        }
                        .onEnded { value in
                            isDragging = false
                            withAnimation(.easeOut(duration: 0.2)) {
                                if value.translation.width < -40 {
                                    offsetX = -80
                                    activeSwipedID = entry.id
                                } else {
                                    offsetX = 0
                                    activeSwipedID = nil
                                }
                            }
                        }
                )
                .onTapGesture {
                    if offsetX != 0 {
                        withAnimation {
                            offsetX = 0
                            activeSwipedID = nil
                        }
                    } else {
                        print("📬 tapped entry: \(entry.title)")
                        onTap?()
                    }
                }
        }
        .onChange(of: activeSwipedID) { newValue in
            if newValue != entry.id && offsetX != 0 {
                withAnimation {
                    offsetX = 0
                }
            }
        }
        .frame(height: entry.mediaFiles?.isEmpty == false ? 250 : 150)

        
        
    }

    var content: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 15) {
                // Date
                VStack(alignment: .center) {
                    Text(formatDate(entry.date, format: "dd"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Text(formatDate(entry.date, format: "MMM"))
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: 50)

                // Content
                VStack(alignment: .leading, spacing: 15) {
                    if let moodNames = entry.moods, !moodNames.isEmpty {
                        HStack {
                            GeometryReader { geo in
                                let availableWidth = geo.size.width
                                let iconWidth: CGFloat = 28
                                let spacing: CGFloat = 5
                                let totalIconWidth = iconWidth + spacing
                                let maxIcons = Int(availableWidth / totalIconWidth)
                                let needsTruncation = moodNames.count > maxIcons
                                let displayedMoods = needsTruncation ? moodNames.prefix(maxIcons - 1) : moodNames.prefix(maxIcons)
                                let extraCount = moodNames.count - displayedMoods.count

                                HStack(spacing: spacing) {
                                    ForEach(displayedMoods, id: \.self) { moodName in
                                        if let mood = Mood.all.first(where: { $0.name == moodName }) {
                                            Image(mood.imageName)
                                                .resizable()
                                                .frame(width: iconWidth, height: iconWidth)
                                        } else {
                                            Text(moodName)
                                                .font(.headline)
                                        }
                                    }

                                    if needsTruncation {
                                        Text("+\(extraCount)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .frame(height: 25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !entry.title.isEmpty {
                        Text(entry.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }

                    Text(entry.content)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .lineLimit(2)

                    if let media = entry.mediaFiles, !media.isEmpty {
                        GeometryReader { geo in
                            let totalWidth = CGFloat(media.count) * 90
                            if totalWidth > geo.size.width {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    imageRow(media: media, geometry: geo)
                                }
                            } else {
                                imageRow(media: media, geometry: geo)
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
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
            )
        }
    }

    func imageRow(media: [String], geometry: GeometryProxy) -> some View {
        HStack {
            ForEach(media, id: \.self) { item in
                imageView(for: item)
            }
        }
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    func imageView(for mediaItem: String) -> some View {
        Group {
            if mediaItem.hasPrefix("http") {
                AsyncImage(url: URL(string: mediaItem)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        ProgressView()
                    }
                }
            } else {
                Image(mediaItem)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

struct EntryListBlockView_Previews: PreviewProvider {
    @State static var dummyActiveSwipedID: String? = nil
    static var previews: some View {
        VStack {
            EntryListBlockView(
                entry: Entry(
                    id: "1",
                    journalID: "work",
                    userID: "testuser@example.com",
                    title: "Meeting Notes",
                    content: "Had a great meeting today about the new project...",
                    date: Date(),
                    moods: ["😊", "🚀"],
                    mediaFiles: ["sample-image", "sample-image"],
                    tags: []
                ),
                activeSwipedID: $dummyActiveSwipedID,
                onDelete: {}
            )

            EntryListBlockView(
                entry: Entry(
                    id: "2",
                    journalID: "personal",
                    userID: "testuser@example.com",
                    title: "Daily Reflection",
                    content: "Today was a good day.",
                    date: Date(),
                    moods: ["😌"],
                    mediaFiles: [],
                    tags: []
                ),
                activeSwipedID: $dummyActiveSwipedID,
                onDelete: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
