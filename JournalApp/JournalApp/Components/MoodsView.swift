//
//  MoodsView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//

import SwiftUI

struct MoodsView: View {
    let selectedMoods: [String]

    var body: some View {
        if !selectedMoods.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(selectedMoods, id: \.self) { mood in

                        if let image = UIImage(named: mood) ?? UIImage(systemName: "questionmark.circle") {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(6)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                                .onAppear {
                                    print("Rendering mood image: \(mood)")
                                }
                        } else {
                            // Optional: fallback view so SwiftUI has something to render
                            Circle()
                                .fill(Color.red.opacity(0.3))
                                .frame(width: 30, height: 30)
                                .overlay(Text("?"))
                        }

                    }
                }
            }
        }
    }
}

struct MoodsView_Previews: PreviewProvider {
    static var previews: some View {
        MoodsView(selectedMoods: ["happy", "tired", "excited"])
    }
}
