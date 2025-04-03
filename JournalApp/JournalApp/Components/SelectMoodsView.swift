//
//  SelectMoodsView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//

import SwiftUI

struct SelectMoodsView: View {
    @Binding var selectedMoods: [String]
    let availableMoods: [Mood]

    let columns = Array(repeating: GridItem(.flexible()), count: 5)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(availableMoods) { mood in
                    Button(action: {
                        toggleMood(mood.name)
                    }) {
                        Image(mood.imageName)
                            .resizable()
                            .frame(width: 28, height: 28)
                            .padding(6)
                            .background(
                                selectedMoods.contains(mood.name)
                                    ? Color.gray.opacity(0.2)
                                    : Color.clear
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
        }
//        .frame(maxWidth: 200, maxHeight: 180) // Compact height
//        .background(Color(.systemBackground))
//        .cornerRadius(14)
//        .shadow(radius: 10)
        .frame(width: 200, height: 150)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }

    private func toggleMood(_ mood: String) {
        if selectedMoods.contains(mood) {
            selectedMoods.removeAll { $0 == mood }
        } else {
            selectedMoods.append(mood)
        }
    }
}

struct SelectMoodsView_Previews: PreviewProvider {
    @State static var selected = ["happy", "tired"]

    static var previews: some View {
        SelectMoodsView(
            selectedMoods: $selected,
            availableMoods: Mood.all
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
