//
//  JournalAppApp.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct JournalAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView() // ✅ this should be the ONLY view loaded at launch
                .environmentObject(appState)
        }
    }
}
