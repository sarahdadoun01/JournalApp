//
//  SideBarItem.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-22.
//

import SwiftUI

struct SideBarItem: View {
    let title: String
    let iconName: String?
    let count: Int?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack{
                HStack {
                    
                    if let iconName = iconName {
                        Image(systemName: iconName)
                            .foregroundColor(.purple)
                    }
                    
                    Text(title)
                        .foregroundColor(.primary)

                    Spacer()

                    if let count = count {
                        Text("\(count)")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                .cornerRadius(8)
            }
            
        }
    }
}

struct SideBarItem_Previews: PreviewProvider {
    static var previews: some View {
        SideBarItem(
            title: "Sample",
            iconName: "star.fill",
            count: 5,
            isSelected: true,
            action: {}
        )
    }
}
