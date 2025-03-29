//
//  SignUpCreatePasscodeView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

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

    var body: some View {
        VStack(spacing: 24) {
            Text("Create a Passcode")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)

            Text("This passcode will protect your journal.")
                .foregroundColor(.gray)

            ZStack(alignment: .trailing) {
                if showAlphanumeric {
                    if showPasscode {
                        TextField("Enter alphanumeric passcode", text: $passcode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                    } else {
                        SecureField("Enter alphanumeric passcode", text: $passcode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                    }
                } else {
                    if showPasscode {
                        TextField("Enter 4-digit passcode", text: $passcode)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .frame(width: 200)
                            .multilineTextAlignment(.center)
                            .padding(.trailing, 30)
                    } else {
                        SecureField("Enter 4-digit passcode", text: $passcode)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .frame(width: 200)
                            .multilineTextAlignment(.center)
                            .padding(.trailing, 30)
                    }
                }

                Button(action: {
                    showPasscode.toggle()
                }) {
                    Image(systemName: showPasscode ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.trailing, showAlphanumeric ? 30 : 0)
                }
            }

            Toggle("Alphanumeric", isOn: $showAlphanumeric)
                .padding(.horizontal)

            NavigationLink(
                destination: SignUpSuccessView(
                    firstName: firstName
                ),
                isActive: $showNext
            ) {
                EmptyView()
            }

            Button(action: {
                if passcode.isEmpty || (!showAlphanumeric && passcode.count != 4) {
                    showAlert = true
                    return
                }

                FirebaseService.shared.createUserAccount(
                    firstName: firstName,
                    lastName: lastName,
                    birthday: birthday,
                    email: email,
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
            }) {
                Text("Next")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.clear)
                    .foregroundColor(Color(hex: "#1A1F3B"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 150)
                            .stroke(Color(hex: "#B9B9B9"), lineWidth: 1)
                    )
                    .cornerRadius(150)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("Passcode")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Missing Info"),
                message: Text("Please enter a valid passcode."),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: passcode) { newValue in
            if !showAlphanumeric && newValue.count > 4 {
                passcode = String(newValue.prefix(4))
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)

        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let r = Double((color >> 16) & 0xFF) / 255.0
        let g = Double((color >> 8) & 0xFF) / 255.0
        let b = Double(color & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
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
