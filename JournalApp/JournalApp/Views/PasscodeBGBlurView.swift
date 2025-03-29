//
//  PasscodeBGBlurView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-27.
//

import SwiftUI
import FirebaseAuth

struct PasscodeBGBlurView: View {
    @State private var isLocked = true
    @State private var inputPasscode = ""
    @State private var animateDismiss = false  // Controls slide-down animation

    var body: some View {
        ZStack {
            // Main app content
            HomeView()
            
            // If locked, overlay with a blur and passcode screen
            if isLocked {
                Rectangle()
                    .fill(.regularMaterial)
                    .ignoresSafeArea()
                
                // Use the currentUser’s UID from FirebaseAuth
                if let uid = Auth.auth().currentUser?.uid {
                    PasscodeUnlock(
                        userID: uid,
                        inputPasscode: $inputPasscode
                    ) {
                        // When passcode is successfully verified close with animation
                        withAnimation(.easeInOut(duration: 1.0)) {
                            animateDismiss = true
                        }
                        // remove the overlay and unlock the app
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isLocked = false
                        }
                    }
                    .padding()
                    // slide the PasscodeUnlock view downward when animateDismiss is true
                    .offset(y: animateDismiss ? UIScreen.main.bounds.height : 0)
                    .animation(.easeInOut(duration: 1.0), value: animateDismiss)
                } else {
                    Text("No user logged in")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct PasscodeBGBlurView_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeBGBlurView()
    }
}
