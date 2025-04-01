//
//  LoginView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-21.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSecure: Bool = true
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var path = NavigationPath()
    @State private var animateDismiss = false
    
//    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false


    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                // Top Header (fixed at top)
                VStack(spacing: 8) {
                    Text("Welcome Back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Login if you already have an account.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 60)
                .hideKeyboardOnTap()

                Spacer()

                // Centered Content
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        CustomTextFieldView(
                            text: $email,
                            placeholder: "Email",
                            autocapitalization: .never,
                            horizontalPadding: 20,
                            verticalPadding: 15,
                            cornerRadius: 999,
                            backgroundColor: .clear,
                            borderColor: Color(hex: "#D9D9D9")
                        )

                        CustomSecureFieldView(
                            text: $password,
                            placeholder: "Password",
                            horizontalPadding: 20,
                            verticalPadding: 15,
                            cornerRadius: 999,
                            backgroundColor: .clear,
                            borderColor: Color(hex: "#D9D9D9"),
                            textColor: .gray
                        )

                        HStack {
                            Spacer()
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
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                        }
                    }.padding()
                    .hideKeyboardOnTap()

                    // Login & Face ID buttons
                    VStack(spacing: 16) {
                        RoundedBorderButtonView(
                            title: "Log In",
                            action: {
                                if email.isEmpty || password.isEmpty {
                                    alertMessage = "Please enter both email and password."
                                    showingAlert = true
                                } else {
                                    FirebaseService.shared.logIn(email: email, password: password) { result in
                                        switch result {
                                        case .success():
//                                            isLoggedIn = true
                                            withAnimation(.easeInOut(duration: 1.0)) {
                                                appState.isLoggedIn = true
                                                appState.triggerPasscode()
                                            }
                                        case .failure(let error):
                                            alertMessage = error.localizedDescription
                                            showingAlert = true
                                        }
                                    }
                                }
                            },
                            backgroundColor: .black,
                            textColor: .white,
                            horizontalPadding: 30,
                            verticalPadding: 20
                        )
                    }
                }.hideKeyboardOnTap()

                Spacer()

                HStack {
                    // Sign Up Button (left)
                    Button(action: {
                        path.append(SignUpRoute.emailPass(firstName: "", lastName: "", birthday: Date()))
                    }) {
                        Text("Sign\nUp")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(14)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                            )
                    }

                    Spacer()

                    // Face ID Button (right)
                    CircularIconButtonView(
                        systemName: "faceid",
                        size: 80,
                        padding: 27,
                        backgroundColor: .clear,
                        borderColor: Color(hex: "#E0E0E0"),
                        iconColor: .black
                    ) {
                        BiometricAuthService.authenticate { success, errorMessage in
                            if success {
                                // Log in or proceed
                            } else {
                                alertMessage = errorMessage ?? "Login failed"
                                showingAlert = true
                            }
                        }
                    }
                }.padding(.horizontal, 5)
                .padding(.bottom, -10)
                .hideKeyboardOnTap()

            }
            .padding(.horizontal)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Notice"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(for: String.self) { value in
                if value == "passcode" {
                    PasscodeBGBlurView(
                        isLoggedIn: $appState.isLoggedIn,
                        animateDismiss: animateDismiss
                    )
                }
            }
            .navigationDestination(for: SignUpRoute.self) { route in
                switch route {
                case .emailPass(let first, let last, let birthday):
                    SignUpEmailPassView(firstName: first, lastName: last, birthday: birthday)
                }
            }

            .hideKeyboardOnTap()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
