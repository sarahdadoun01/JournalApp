//
//  SignUpCreatePasscodeView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import SwiftUI

struct SignUpCreatePasscodeView: View {
    let firstName: String
    let lastName: String
    let birthday: Date
    let email: String
    let password: String

    @State private var passcode: String = ""
    @State private var showAlphanumeric = false
    @State private var showPasscode = false
    @State private var showNext = false
    @State private var showAlert = false

    @Environment(\.dismiss) private var dismiss

    private var isPasscodeValid: Bool {
        if showAlphanumeric {
            return !passcode.isEmpty
        } else {
            return passcode.count == 4
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Back Button
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

            ScrollView {
                VStack(spacing: 24) {
                    Text("Create a Passcode")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Required on every app \nlaunch to maintain privacy.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        

                    // Passcode Field
                    ZStack(alignment: .trailing) {
                        CustomSecureFieldView(
                            text: $passcode,
                            placeholder: showAlphanumeric ? "Enter alphanumeric passcode" : "4-digits",
                            horizontalPadding: 20,
                            verticalPadding: 20,
                            cornerRadius: 10,
                            backgroundColor: Color(.systemGray6),
                            borderColor: .clear,
                            textColor: .primary
                        )
                        .keyboardType(showAlphanumeric ? .default : .numberPad)
                        .frame(width: showAlphanumeric ? nil : 200)
                        .multilineTextAlignment(showAlphanumeric ? .leading : .center)
                        .padding(.horizontal)

                    }

                    // Alphanumeric Toggle Styled as Button
                    RoundedBorderButtonView(
                        title: showAlphanumeric ? "Alphanumeric ✓" : "Alphanumeric",
                        action: {
                            showAlphanumeric.toggle()
                        },
                        backgroundColor: .clear,
                        borderColor: Color(hex: "#D6D6D6"),
                        textColor: .gray,
                        horizontalPadding: 20,
                        verticalPadding: 10
                    )
                }
                .padding(.top, 60)
                .padding(.bottom, 150)
            }
            .scrollDismissesKeyboard(.interactively)

            Spacer()

            NavigationLink(
                destination: SignUpSuccessView(firstName: firstName),
                isActive: $showNext
            ) {
                EmptyView()
            }

            // Next Button
            RoundedBorderButtonView(
                title: "Next",
                action: {
                    if !isPasscodeValid {
                        showAlert = true
                        return
                    }

                    let lowercasedEmail = email.lowercased()
                    FirebaseService.shared.createUserAccount(
                        firstName: firstName,
                        lastName: lastName,
                        birthday: birthday,
                        email: lowercasedEmail,
                        password: password,
                        passcode: passcode
                    ) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let uid):
                                print("✅ Account created and stored with UID: \(uid)")
                                showNext = true
                            case .failure(let error):
                                print("❌ Error creating account: \(error.localizedDescription)")
                                showAlert = true
                            }
                        }
                    }
                },
                backgroundColor: isPasscodeValid ? .black : .gray,
                textColor: .white,
                horizontalPadding: 30,
                verticalPadding: 20
            )
            .disabled(!isPasscodeValid)
            .opacity(isPasscodeValid ? 1 : 0.5)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Missing Info"),
                message: Text("Please enter a valid passcode."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: passcode) { newValue in
            if !showAlphanumeric && newValue.count > 4 {
                passcode = String(newValue.prefix(4))
            }
        }
        .hideKeyboardOnTap()
    }
}

struct SignUpCreatePasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpCreatePasscodeView(
                firstName: "Sarah",
                lastName: "Radium",
                birthday: Date(),
                email: "sarah@example.com",
                password: "password123"
            )
        }
    }
}

