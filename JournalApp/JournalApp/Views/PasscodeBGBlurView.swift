//
//  PasscodeBGBlurView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-27.
//

import SwiftUI
import FirebaseAuth

public struct PasscodeBGBlurView: View {
    @EnvironmentObject var appState: AppState

    @Binding var isLoggedIn: Bool
    @State var isLocked = true
    @State var inputPasscode: String = ""
    @State var animateDismiss: Bool  // Controls slide-down animation

    public var body: some View {
        ZStack {
            // Show the app underneath, blurred
            HomeView()
                .blur(radius: isLocked ? 10 : 0) // ✅ apply visual blur here

            if isLocked {
                ZStack {
                    // ✅ Soft blur background using blur instead of a blocking color
                    Color.clear
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()

                    VStack {
                        Spacer()
                        PasscodeUnlock(
                            userID: Auth.auth().currentUser?.uid ?? "preview",
                            inputPasscode: $inputPasscode
                        ) {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                animateDismiss = true
                                isLocked = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                isLocked = false
                                appState.blurOverlay = false // ✅ ADD THIS LINE
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.95)) // ✅ visible & tappable
                        .cornerRadius(40)
                        .shadow(color: Color.black.opacity(0.1), radius: 40.0, x: 0, y: 0)
                        .frame(maxWidth: 300)
                        Spacer()
                    }
                }
            }
        }
    }
}


struct PasscodeBGBlurView_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeBGBlurView(
            isLoggedIn: .constant(true),
            isLocked: true,
            inputPasscode: "",
            animateDismiss: false
        )
    }
}
