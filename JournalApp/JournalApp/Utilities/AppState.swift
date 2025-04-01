//
//  AppState.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-31.
//

import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class AppState: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @Published var needsPasscode: Bool = false
    @Published var blurOverlay: Bool = false

    private var hasLaunched = false

    init() {
        // Ensure login status matches Firebase
        if Auth.auth().currentUser == nil {
            isLoggedIn = false
        }

        // Show passcode on launch if logged in
        if isLoggedIn {
            triggerPasscode()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }

            Task { @MainActor in
                if self.isLoggedIn {
                    print("📲 App entering foreground — forcing passcode trigger")
                    self.blurOverlay = true
                    self.triggerPasscode()
                }
            }
        }

    }
    @MainActor
    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background:
            if isLoggedIn {
                print("🌒 App backgrounded — show blur")
                blurOverlay = true
            }

        case .inactive:
            if isLoggedIn {
                print("😴 App became inactive (multitask?) — show blur")
                blurOverlay = true
            }

        case .active:
            if isLoggedIn {
                print("☀️ App resumed — show passcode")
                blurOverlay = true
                triggerPasscode()
            }

        default:
            break
        }
    }


    func triggerPasscode() {
        needsPasscode = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.needsPasscode = true
        }
    }

    func logout() {
        do {
            try FirebaseService.shared.signOut()
            isLoggedIn = false
            needsPasscode = false
            blurOverlay = false
        } catch {
            print("❌ Logout failed: \(error)")
        }
    }
}
