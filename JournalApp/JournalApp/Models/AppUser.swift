//
//  AppUser.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import Foundation

struct AppUser: Identifiable, Codable {
    var id: String // userID
    var email: String
    var birthday: Date
}
