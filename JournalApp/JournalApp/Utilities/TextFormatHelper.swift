//
//  TextFormatHelper.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-01.
//

import Foundation

enum TextFormatStyle {
    case bold, italic, underline, listBullet, listNumber
    case increaseSize, decreaseSize
}

struct TextFormatHelper {
    static func applyFormat(_ style: TextFormatStyle, to text: String) -> String {
        switch style {
        case .bold:
            return "**\(text)**"
        case .italic:
            return "_\(text)_"
        case .underline:
            return "__\(text)__"
        case .listBullet:
            return text
                .split(separator: "\n")
                .map { "• \($0)" }
                .joined(separator: "\n")
        case .listNumber:
            return text
                .split(separator: "\n")
                .enumerated()
                .map { "\($0.offset + 1). \($0.element)" }
                .joined(separator: "\n")
        case .increaseSize:
            return "[size:+1]\(text)[/size]"
        case .decreaseSize:
            return "[size:-1]\(text)[/size]"
        }
    }
}
