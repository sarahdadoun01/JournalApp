//
//  SignUpSuccessView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import SwiftUI

struct SignUpSuccessView: View {
    let firstName: String

    @State private var navigateToHome = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            LottieView(animationName: "checkmark_animation")
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding()

            Text("Welcome, \(firstName)!")
                .font(.title)
                .fontWeight(.bold)

            Text("Your account has been successfully created.\nEnjoy your peace of mind.")
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.horizontal)

            Spacer()

            RoundedBorderButtonView(
                title: "Explore",
                action: { navigateToHome = true },
                backgroundColor: .black,
                textColor: .white,
                horizontalPadding: 30,
                verticalPadding: 20
            )
            
            .padding()
            .previewLayout(.sizeThatFits)
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
            firstName: "Sarah"
        )
    }
}
