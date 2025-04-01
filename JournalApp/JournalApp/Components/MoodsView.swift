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
                        Image(mood)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(6)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MoodsView_Previews: PreviewProvider {
    static var previews: some View {
        MoodsView(selectedMoods: ["happy", "tired", "excited"])
    }
}
