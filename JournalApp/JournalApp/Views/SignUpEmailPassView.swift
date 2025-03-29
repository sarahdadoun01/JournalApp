//
//  SignUpEmailPassView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpEmailPassView: View {
    var firstName: String
    var lastName: String
    var birthday: Date

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToPasscode = false
    @State private var createdUID: String = ""
    
    private var isFormValid: Bool {
        ValidationHelper.isLoginFormValid(
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
    }
    
    private var passwordsMatch: Bool {
        password.isEmpty || confirmPassword.isEmpty || password == confirmPassword
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            HStack {
                CircularIconButtonView(
                    systemName: "chevron.left",
                    size: 40,
                    padding: 15,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D6D6D6"),
                    iconColor: .black
                ) {
                    dismiss()
                }

                Spacer()
            }
            .padding(.top, 8)
            .padding(.leading)
            
            Spacer()

            VStack(spacing: 10) {

                // Title
                Text("Create Login Info")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 40)

                // Email Field
                CustomTextFieldView(
                    text: $email,
                    placeholder: "Email",
                    autocapitalization: .never,
                    horizontalPadding: 25,
                    verticalPadding: 20,
                    cornerRadius: 999,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D6D6D6")
                )

                // Password Field
                CustomSecureFieldView(
                    text: $password,
                    placeholder: "Password",
                    horizontalPadding: 25,
                    verticalPadding: 20,
                    cornerRadius: 999,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D6D6D6")
                )

                // Confirm Password Field
                CustomSecureFieldView(
                    text: $confirmPassword,
                    placeholder: "Confirm Password",
                    horizontalPadding: 25,
                    verticalPadding: 20,
                    cornerRadius: 999,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D6D6D6")
                )
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            Group {
                if !passwordsMatch {
                    Text("Passwords do not match.")
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    Text(" ") // invisible placeholder to keep the height
                        .font(.caption)
                        .opacity(0)
                }
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity, alignment: .leading)


            Spacer()

            // Next Button
            RoundedBorderButtonView(
                title: "Next",
                action: {
                    navigateToPasscode = true
                },
                backgroundColor: isFormValid ? .black : .gray,
                textColor: .white,
                horizontalPadding: 30,
                verticalPadding: 20
            )
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1 : 0.5)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .background(
            NavigationLink(
                destination: SignUpCreatePasscodeView(
                    firstName: firstName,
                    lastName: lastName,
                    birthday: birthday,
                    email: email,
                    password: password
                ),
                isActive: $navigateToPasscode
            ) {
                EmptyView()
            }
        )
        .hideKeyboardOnTap()
    }
}

struct SignUpEmailPassView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpEmailPassView(
            firstName: "Sarah",
            lastName: "Dadoun",
            birthday: Date()
        )
    }
}
