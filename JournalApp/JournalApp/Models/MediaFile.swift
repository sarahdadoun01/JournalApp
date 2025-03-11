//
//  MediaFile.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-25.
//

import Foundation

struct MediaFile: Identifiable, Codable{
    var id: String //fileid
    var entryID: String
    var fileURL: String
    var fileType: MediaType
}


enum MediaType: String, Codable {
    case image, video, audio
}
