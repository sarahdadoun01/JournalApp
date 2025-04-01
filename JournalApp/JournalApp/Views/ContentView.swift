//
//  ContentView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-24.
//
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var appState = AppState()

    var body: some View {
        ZStack {
            if appState.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }

            // Blur overlay ONLY when app is multitasked
            if appState.blurOverlay {
                Color.black
                    .opacity(0.6)
                    .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $appState.needsPasscode) {
            PasscodeBGBlurView(
                isLoggedIn: $appState.isLoggedIn,
                animateDismiss: true
            )
            .environmentObject(appState)
        }
        .onChange(of: scenePhase) { value in
            appState.handleScenePhase(value)
        }
        .environmentObject(appState)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
