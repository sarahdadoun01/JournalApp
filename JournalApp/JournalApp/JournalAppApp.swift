//
//  JournalAppApp.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-24.
//

//import SwiftUI
//
//@main
//struct JournalAppApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}


import SwiftUI
import FirebaseCore

@main
struct JournalAppApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


