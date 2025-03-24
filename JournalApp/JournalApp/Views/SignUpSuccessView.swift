//
//  SignUpSuccessView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import SwiftUI

struct SignUpSuccessView: View {
    let firstName: String
    let lastName: String
    let birthday: Date
    let email: String
    let password: String
    let passcode: String

    @State private var navigateToHome = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
                .padding()

            Text("Account Created")
                .font(.title)
                .fontWeight(.bold)

            Text("Welcome, \(firstName)! You're all set.")
                .foregroundColor(.gray)

            Spacer()

            Button(action: {
                navigateToHome = true
            }) {
                Text("Start Writing")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SignUpSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpSuccessView(
            firstName: "Sarah",
            lastName: "Dadoun",
            birthday: Date(),
            email: "sarah@example.com",
            password: "password123",
            passcode: "1234"
        )
    }
}
