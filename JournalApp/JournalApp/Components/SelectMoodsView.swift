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
                        if let image = UIImage(named: mood.imageName) ?? UIImage(systemName: "questionmark.circle") {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 28, height: 28)
                                .padding(6)
                                .background(
                                    selectedMoods.contains(mood.name)
                                        ? Color.gray.opacity(0.2)
                                        : Color.clear
                                )
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.red.opacity(0.3))
                                .frame(width: 28, height: 28)
                                .overlay(Text("?"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
        }
        .frame(width: 200, height: 150)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 0)

    }

    private func toggleMood(_ mood: String) {
        print("Tapped mood: \(mood)")
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
