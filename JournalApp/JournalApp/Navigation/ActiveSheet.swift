//
//  ActiveSheet.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-01.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case mediaMenu
    case mediaViewer
    case imagePicker
    case voiceRecorder
    case journalPicker
    case moodPicker

    var id: String {
        switch self {
        case .mediaMenu: return "mediaMenu"
        case .mediaViewer: return "mediaViewer"
        case .imagePicker: return "imagePicker"
        case .voiceRecorder: return "voiceRecorder"
        case .journalPicker: return "journalPicker"
        case .moodPicker: return "moodPicker"
        }
    }
}
