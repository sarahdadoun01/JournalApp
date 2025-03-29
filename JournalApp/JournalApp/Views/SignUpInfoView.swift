//
//  SignUpInfoView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

//import SwiftUI
//
//struct SignUpInfoView: View {
//    @State private var firstName: String = ""
//    @State private var lastName: String = ""
//    @State private var birthday: Date = Date()
//    @State private var showNext = false
//    @State private var showAlert = false
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 24) {
//            Text("Basic Info")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding(.top, 16)
//
//            TextField("First Name", text: $firstName)
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//
//            TextField("Last Name", text: $lastName)
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//
//            HStack {
//                Text("Birthday")
//                    .foregroundColor(.gray)
//                Spacer()
//                DatePicker("", selection: $birthday, displayedComponents: .date)
//                    .labelsHidden()
//            }
//
//            Spacer()
//
//            NavigationLink(
//                destination: SignUpEmailPassView(
//                    firstName: firstName,
//                    lastName: lastName,
//                    birthday: birthday
//                ),
//                isActive: $showNext
//            ) {
//                Button(action: {
//                    if firstName.isEmpty || lastName.isEmpty {
//                        showAlert = true
//                    } else {
//                        showNext = true
//                    }
//                }) {
//                    Text("Next")
//                        .fontWeight(.semibold)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                }
//            }
//        }
//        .padding()
//        .navigationTitle("Create Account")
//        .navigationBarTitleDisplayMode(.inline)
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text("Missing Info"), message: Text("Please enter both first and last names."), dismissButton: .default(Text("OK")))
//        }
//    }
//}
//
//struct SignUpInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            SignUpInfoView()
//        }
//    }
//}

import SwiftUI

enum SignUpRoute: Hashable {
    case emailPass(firstName: String, lastName: String, birthday: Date)
}

struct SignUpInfoView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var birthday: Date = Date()
    @State private var showAlert = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Basic Info")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 16)

                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    TextField("Last Name", text: $lastName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    HStack {
                        Text("Birthday")
                            .foregroundColor(.gray)
                        Spacer()
                        DatePicker("", selection: $birthday, displayedComponents: .date)
                            .labelsHidden()
                    }
                }

                Spacer()

                Button(action: {
                    if firstName.isEmpty || lastName.isEmpty {
                        showAlert = true
                    } else {
                        path.append(SignUpRoute.emailPass(firstName: firstName, lastName: lastName, birthday: birthday))
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
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Missing Info"),
                    message: Text("Please enter both first and last names."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(for: SignUpRoute.self) { route in
                switch route {
                case let .emailPass(first, last, bday):
                    SignUpEmailPassView(firstName: first, lastName: last, birthday: bday)
                }
            }
        }
    }
}

struct SignUpInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpInfoView()
    }
}

