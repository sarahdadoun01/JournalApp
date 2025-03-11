//
//  ContentView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseService = FirebaseService()

    var body: some View {
        NavigationView {
            VStack {
                Text("Journal App")
                    .font(.title)
                
                Button("Test Firestore") {
                    Task {
                        await firebaseService.testFirestoreConnection()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
