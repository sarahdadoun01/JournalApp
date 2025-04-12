//
//  WaveformView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-04-08.
//

import SwiftUI

struct WaveformView: View {
    @Binding var isAnimating: Bool
    private let barCount = 12

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<barCount, id: \.self) { index in
                Capsule()
                    .fill(.blue)
                    .frame(width: 3, height: isAnimating ? CGFloat.random(in: 10...20) : 10)
                    .animation(
                        Animation.easeInOut(duration: 0.25)
                            .repeatForever()
                            .delay(Double(index) * 0.05),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            if isAnimating {
                withAnimation { }
            }
        }
    }
}
