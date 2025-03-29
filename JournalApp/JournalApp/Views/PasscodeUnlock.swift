//
//  PasscodeUnlock.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import SwiftUI
import LocalAuthentication

struct PasscodeUnlock: View {
    let userID: String
    @Binding var inputPasscode: String
    var onPasscodeEntered: () -> Void

    @State private var errorMessage: String?
    @State private var isUnlocked = false
    private let passcodeLength = 4

    var body: some View {
        ZStack {
            // Full-screen purple background
//            Color.purple
//                .ignoresSafeArea()

            if isUnlocked {
                // When unlocked, you might navigate away or remove this view
                Text("Unlocked")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            } else {
                // Passcode UI
                VStack(spacing: 20) {
                    Text("Enter Journal Passcode")
                        .font(.headline)
                        .foregroundColor(.black)

                    // 4 Dot Indicators
                    HStack(spacing: 16) {
                        ForEach(0..<passcodeLength, id: \.self) { index in
                            Circle()
                                .strokeBorder(Color.black, lineWidth: 1)
                                .frame(width: 13, height: 13)
                                .background(
                                    Circle().fill(index < inputPasscode.count ? Color.black : Color.clear)
                                )
                        }
                    }.padding(.vertical)
                    
                    // Numeric Keypad
                    KeypadView(
                        onDigit: { digit in
                            inputPasscode.append(digit)
                            if inputPasscode.count == passcodeLength {
                                print("Verifying passcode for UID: \(userID)")
                                FirebaseService.shared.verifyPasscodeForUser(uid: userID, typedPasscode: inputPasscode) { isCorrect in
                                    if isCorrect {
                                        isUnlocked = true
                                        onPasscodeEntered()
                                    } else {
                                        errorMessage = "Invalid passcode. UID: \(userID), TypedPasscode: \(inputPasscode) Try again."
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            inputPasscode = ""
                                        }
                                    }
                                }
                            }
                        },
                        onBiometric: {
                            authenticateWithFaceID()
                        },
                        onDelete: {
                            if !inputPasscode.isEmpty {
                                inputPasscode.removeLast()
                            }
                        }
                    )
                    
                    // Display error message if needed
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Biometric Authentication
    private func authenticateWithFaceID() {
        let context = LAContext()
        context.localizedFallbackTitle = ""  // Hide system fallback
        let reason = "Unlock your journal"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        onPasscodeEntered()
                    } else {
                        errorMessage = "Face ID failed. Enter your passcode."
                    }
                }
            }
        } else {
            errorMessage = "Face ID not available. Enter your passcode."
        }
    }
}

struct PasscodeUnlock_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeUnlock(userID: "testUID", inputPasscode: .constant("")) {
            print("Unlocked!")
        }
    }
}
