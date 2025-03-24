//
//  TagModel.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-22.
//

//
//  TagModel.swift
//  JournalApp
//
//  Created by Sarah on [Date].
//

import Foundation
import UIKit

struct Tag: Identifiable, Codable, Hashable {
    var id: String // manually set from Firestore document ID
    var name: String
    var colorHex: String

    init(id: String, name: String, colorHex: String = "#007BFF") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    var color: UIColor {
        return UIColor(hex: colorHex) ?? .systemBlue
    }

    // Init from Firestore dictionary
    init?(id: String, data: [String: Any]) {
        guard let name = data["name"] as? String,
              let colorHex = data["colorHex"] as? String else {
            return nil
        }
        self.init(id: id, name: name, colorHex: colorHex)
    }

    // Convert to Firestore dictionary
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "colorHex": colorHex
        ]
    }
}


extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
