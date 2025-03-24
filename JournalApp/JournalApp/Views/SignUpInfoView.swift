//
//  SignUpInfoView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import SwiftUI

struct SignUpInfoView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthday = Date()
    @State private var showNext = false
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Basic Info")
                .font(.title)
                .fontWeight(.bold)

            TextField("First Name", text: $firstName)
                .textContentType(.givenName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            TextField("Last Name", text: $lastName)
                .textContentType(.familyName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()

            Spacer()

            Button(action: {
                if firstName.isEmpty || lastName.isEmpty {
                    showAlert = true
                } else {
                    showNext = true
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
        .navigationDestination(isPresented: $showNext) {
            SignUpEmailPassView(
                firstName: firstName,
                lastName: lastName,
                birthday: birthday
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Missing Info"),
                message: Text("Please fill in your first and last name."),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle("Create Account")
    }
}


struct SignUpInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpInfoView()
    }
}
