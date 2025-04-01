//
//  SignUpInfoView.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-03-24.
//

import SwiftUI

enum SignUpRoute: Hashable {
    case emailPass(firstName: String, lastName: String, birthday: Date)
}

struct SignUpInfoView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var birthday: Date = Date()
    @State private var showAlert = false
    @State private var showDatePicker = false
    
    private var isBirthdayValid: Bool {
        ValidationHelper.isBirthdayValid(birthday)
    }

    private var isFormValid: Bool {
        ValidationHelper.isNameFormValid(firstName: firstName, lastName: lastName, birthday: birthday)
    }
    
    @Binding var path: NavigationPath
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            HStack {
                CircularIconButtonView(
                    systemName: "chevron.left",
                    size: 40,
                    padding: 15,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D9D9D9"),
                    iconColor: .black
                ) {
                    dismiss()
                }

                Spacer()
            }
            .padding(.top, 8)
            .padding(.leading)
            .hideKeyboardOnTap()
            
            Spacer()

            VStack(spacing: 10) {
                Text("Basic Info")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)

                CustomTextFieldView(
                    text: $firstName,
                    placeholder: "First Name",
                    horizontalPadding: 25,
                    verticalPadding: 20,
                    cornerRadius: 999,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D9D9D9")
                )

                CustomTextFieldView(
                    text: $lastName,
                    placeholder: "Last Name",
                    horizontalPadding: 25,
                    verticalPadding: 20,
                    cornerRadius: 999,
                    backgroundColor: .clear,
                    borderColor: Color(hex: "#D9D9D9")
                )

                Button {
                    showDatePicker = true
                } label: {
                    Text(birthday.formatted(date: .long, time: .omitted))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 20)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color(hex: "#D6D6D6"), lineWidth: 1)
                        )
                        .cornerRadius(999)
                        .foregroundColor(.black)
                }
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        DatePicker(
                            "Select Your Birthday",
                            selection: $birthday,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()

                        Button("Done") {
                            showDatePicker = false
                        }
                        .padding()
                    }
                    .presentationDetents([.height(300)])
                }
            }
            .padding(.horizontal, 24)
            .hideKeyboardOnTap()

            Spacer()

            RoundedBorderButtonView(
                title: "Next",
                action: {
                    path.append(SignUpRoute.emailPass(
                        firstName: firstName,
                        lastName: lastName,
                        birthday: birthday
                    ))
                },
                backgroundColor: isFormValid ? .black : .gray,
                textColor: .white,
                horizontalPadding: 30,
                verticalPadding: 20
            )
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1 : 0.5)

        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Missing Info"),
                message: Text("Please enter both first and last names."),
                dismissButton: .default(Text("OK"))
            )
        }
        .hideKeyboardOnTap()
    }
}

struct SignUpInfoView_Previews: PreviewProvider {
    @State static var mockPath = NavigationPath()

    static var previews: some View {
        SignUpInfoView(path: $mockPath)
    }
}

