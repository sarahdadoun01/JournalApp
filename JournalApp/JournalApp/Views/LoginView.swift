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
    @State private var isLoggedIn = false
    
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
                    // Forgot Password Button Action
                    Button(action: {
                        FirebaseService.shared.resetPassword(email: email) { result in
                            switch result {
                            case .success():
                                alertMessage = "Password reset email sent!"
                            case .failure(let error):
                                alertMessage = error.localizedDescription
                            }
                            showingAlert = true
                        }
                    }) {
                        Text("Forgot Password?")
                    }

                }

                // Log In Button
                Button(action: {
                    if email.isEmpty || password.isEmpty {
                        alertMessage = "Please enter both email and password."
                        showingAlert = true
                    } else {
                        FirebaseService.shared.logIn(email: email, password: password) { result in
                            switch result {
                            case .success():
                                isLoggedIn = true  // triggers navigation to HomeView
                            case .failure(let error):
                                alertMessage = error.localizedDescription
                                showingAlert = true
                            }
                        }
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

                Button(action: {
                    BiometricAuthService.authenticate { success, errorMessage in
                        if success {
                            // Log the user in, or continue with Firebase
                        } else {
                            alertMessage = errorMessage ?? "Login failed"
                            showingAlert = true
                        }
                    }
                }) {
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
                    NavigationLink(destination: SignUpInfoView()) {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
                .padding(.bottom)
                
                NavigationLink(destination: PasscodeBGBlurView(), isActive: $isLoggedIn) {
                    EmptyView()
                }

                
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
