//
//  ContentView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-24.
//

import SwiftUI

struct ContentView: View {
    @State private var loggedIn = false

    var body: some View {
        ZStack {
            if loggedIn {
                // When logged in, show PasscodeBGBlurView (which in turn shows HomeView + PasscodeUnlock)
                PasscodeBGBlurView()
                    .transition(.move(edge: .top))
            } else {
                // Otherwise, show the login form.
//                LoginView(onLoginSuccess: {
//                    withAnimation(.easeInOut(duration: 1.0)) {
//                        loggedIn = true
//                    }
//                })
//                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: loggedIn)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
