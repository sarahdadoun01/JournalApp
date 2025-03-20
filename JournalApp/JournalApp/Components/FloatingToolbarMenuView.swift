//
//  FloatingToolbarMenuView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-20.
//

import SwiftUI

struct FloatingToolbarMenuView: View {
    var onAddMood: () -> Void
    var onAddText: () -> Void
    var onAddImage: () -> Void
    var onAddVoiceMemo: () -> Void
    var onAddTag: () -> Void
    var onSelectJournal: () -> Void
    
    @State private var isVisible: Bool = true
    
    var body: some View {
        VStack {
            if isVisible {
                HStack(spacing: 20) {
                    ToolbarButton(icon: "face.smiling", action: onAddMood)
                    ToolbarButton(icon: "textformat", action: onAddText)
                    ToolbarButton(icon: "photo.on.rectangle", action: onAddImage)
                    ToolbarButton(icon: "mic", action: onAddVoiceMemo)
                    ToolbarButton(icon: "tag", action: onAddTag)
                    ToolbarButton(icon: "book", action: onSelectJournal)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                //.shadow(radius: 5)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
                .transition(.move(edge: .bottom).combined(with: .opacity))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
            }
        }
        .animation(.easeInOut, value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
}

struct ToolbarButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
                .frame(width: 35, height: 25)
                //.background(Circle().fill(Color.white).shadow(radius: 3))
        }
    }
}

struct FloatingToolbarMenuView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingToolbarMenuView(
            onAddMood: {},
            onAddText: {},
            onAddImage: {},
            onAddVoiceMemo: {},
            onAddTag: {},
            onSelectJournal: {}
        )
        .previewLayout(.sizeThatFits)
    }
}
