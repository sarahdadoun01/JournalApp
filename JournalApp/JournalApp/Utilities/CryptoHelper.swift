//
//  CryptoHelper.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-27.
//

import CryptoKit
import Foundation

func hashPasscode(_ passcode: String, salt: String) -> String {
    let combined = passcode + salt
    let data = Data(combined.utf8)
    let digest = SHA256.hash(data: data)
    return digest.map { String(format: "%02x", $0) }.joined()
}

func generateRandomSalt(length: Int = 16) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
}
