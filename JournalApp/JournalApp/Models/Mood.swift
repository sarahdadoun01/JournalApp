//
//  Mood.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//

import Foundation

struct Mood: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String        // "happy", "sad" ...
    let imageName: String

    static let all: [Mood] = [
        Mood(name: "crying", imageName: "crying"),
        Mood(name: "disappointed", imageName: "disappointed"),
        Mood(name: "evil", imageName: "evil"),
        Mood(name: "excited", imageName: "excited"),
        Mood(name: "extremely-shocked", imageName: "extremely-shocked"),
        Mood(name: "flirty", imageName: "flirty"),
        Mood(name: "happy", imageName: "happy"),
        Mood(name: "investigater", imageName: "investigater"),
        Mood(name: "mad-confused", imageName: "mad-confused"),
        Mood(name: "meh", imageName: "meh"),
        Mood(name: "ok", imageName: "ok"),
        Mood(name: "really-disappointed", imageName: "really-disappointed"),
        Mood(name: "sad", imageName: "sad"),
        Mood(name: "shock", imageName: "shock"),
        Mood(name: "shocked", imageName: "shocked"),
        Mood(name: "silly", imageName: "silly"),
        Mood(name: "speechless", imageName: "speechless"),
        Mood(name: "tired", imageName: "tired"),
        Mood(name: "yucky", imageName: "yucky"),
        Mood(name: "zen", imageName: "zen")
    ]
}
