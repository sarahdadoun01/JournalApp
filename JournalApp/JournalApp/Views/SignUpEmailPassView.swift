//
//  SignUpEmailPassView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import SwiftUI

struct SignUpEmailPassView: View {
    let firstName: String
    let lastName: String
    let birthday: Date

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showNext = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Set up your login")
                .font(.title)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            SecureField("Password", text: $password)
                .textContentType(.newPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            SecureField("Confirm Password", text: $confirmPassword)
                .textContentType(.newPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            Spacer()
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("Back")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Spacer()
                
                Button(action: {
                    guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
                        alertMessage = "All fields are required."
                        showAlert = true
                        return
                    }

                    guard password == confirmPassword else {
                        alertMessage = "Passwords do not match."
                        showAlert = true
                        return
                    }

                    showNext = true
                }) {
                    Text("Next")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.bottom, 10)


            
        }
        .padding()
        .navigationDestination(isPresented: $showNext) {
            SignUpCreatePasscodeView(
                firstName: firstName,
                lastName: lastName,
                birthday: birthday,
                email: email,
                password: password
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Oops!"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Create Account")
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
