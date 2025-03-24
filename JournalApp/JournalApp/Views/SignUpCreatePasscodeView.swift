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

    @State private var passcode = ""
    @State private var isAlphanumeric = false
    @State private var isSecure = true
    @State private var showNext = false
    @State private var showAlert = false

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Create a Passcode")
                .font(.title)
                .fontWeight(.bold)

            Text(isAlphanumeric ? "Use numbers and letters" : "4-digit numeric PIN")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Group {
                    if isSecure {
                        SecureField(isAlphanumeric ? "Enter passcode" : "Enter 4-digit PIN", text: $passcode)
                            .focused($isFocused)
                    } else {
                        TextField(isAlphanumeric ? "Enter passcode" : "Enter 4-digit PIN", text: $passcode)
                            .focused($isFocused)
                    }
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(isAlphanumeric ? .default : .numberPad)
                .padding(.leading)

                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
            }
            .frame(height: 50)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 2)
                    .shadow(color: isFocused ? Color.blue.opacity(0.4) : .clear, radius: 6, x: 0, y: 0)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)


            Toggle(isOn: $isAlphanumeric) {
                Text("Use alphanumeric passcode")
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                let isValid = isAlphanumeric
                    ? passcode.count >= 4
                    : passcode.count == 4 && passcode.allSatisfy(\.isNumber)

                if isValid {
                    showNext = true
                } else {
                    showAlert = true
                }
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
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Passcode"),
                message: Text(isAlphanumeric ? "Passcode must be at least 4 characters." : "PIN must be exactly 4 numbers."),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationDestination(isPresented: $showNext) {
            SignUpSuccessView(
                firstName: firstName,
                lastName: lastName,
                birthday: birthday,
                email: email,
                password: password,
                passcode: passcode
            )
        }
        .navigationTitle("Passcode")
    }
}

struct SignUpCreatePasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpCreatePasscodeView(
            firstName: "Sarah",
            lastName: "Dadoun",
            birthday: Date(),
            email: "sarahcdadoun@gmail.com",
            password: "123456"
        )
    }
}
