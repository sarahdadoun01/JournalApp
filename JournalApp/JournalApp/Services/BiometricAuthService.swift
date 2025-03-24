//
//  BiometricAuthService.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import LocalAuthentication
import Foundation

class BiometricAuthService {
    static func authenticate(reason: String = "Authenticate with Face ID or Touch ID", completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, authError?.localizedDescription ?? "Authentication failed")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, "Biometric authentication is not available on this device")
            }
        }
    }
}
