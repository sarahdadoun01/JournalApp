//
//  LoginView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-21.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSecure: Bool = true
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Login to your journal")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Email Field
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                // Password Field
                Group {
                    if isSecure {
                        SecureField("Password", text: $password)
                    } else {
                        TextField("Password", text: $password)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Spacer()
                        Button(action: {
                            isSecure.toggle()
                        }) {
                            Image(systemName: self.isSecure ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding(.trailing, 10)
                        }
                    }
                )

                // Forgot Password
                HStack {
                    Spacer()
                    Button(action: {
                        alertMessage = "Password reset instructions sent."
                        showingAlert = true
                    }) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }

                // Log In Button
                Button(action: {
                    if email.isEmpty || password.isEmpty {
                        alertMessage = "Please enter both email and password."
                        showingAlert = true
                    } else {
                        // Add your login authentication here
                    }
                }) {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                // Biometric Login
                Button(action: authenticateWithBiometrics) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Log in with Face ID / Touch ID")
                    }
                    .padding(.top, 10)
                    .font(.footnote)
                }

                Spacer()

                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Biometric Authentication
    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Log in using Face ID or Touch ID."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        alertMessage = "Biometric authentication successful!"
                        // Proceed with login flow
                    } else {
                        alertMessage = "Biometric authentication failed."
                    }
                    showingAlert = true
                }
            }
        } else {
            alertMessage = "Biometric authentication not available."
            showingAlert = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
