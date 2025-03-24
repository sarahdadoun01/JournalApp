//
//  GlowingPasscodeFieldView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import SwiftUI

struct GlowingPasscodeFieldView: View {
    @State private var passcode = ""
    @State private var isSecure = true
    @State private var isAlphanumeric = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Passcode")
                .font(.title)

            HStack {
                Group {
                    if isSecure {
                        SecureField("Passcode", text: $passcode)
                            .focused($isFocused)
                    } else {
                        TextField("Passcode", text: $passcode)
                            .focused($isFocused)
                    }
                }
                .autocapitalization(.none)
                .keyboardType(isAlphanumeric ? .default : .numberPad)
                .disableAutocorrection(true)
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
                    .shadow(color: isFocused ? Color.blue.opacity(0.5) : .clear, radius: 8)
            )
            .animation(.easeInOut(duration: 0.3), value: isFocused)

            Spacer()
        }
        .padding()
    }
}

struct GlowingPasscodeFieldView_Previews: PreviewProvider {
    static var previews: some View {
        GlowingPasscodeFieldView()
    }
}
