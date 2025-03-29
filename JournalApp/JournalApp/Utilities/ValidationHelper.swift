//
//  ValidationHelper.swift
//  JournalApp
//
//  Created by Sarah Dadoun on 2025-02-27.
//

import Foundation

struct ValidationHelper {
    static func isBirthdayValid(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let minAgeDate = calendar.date(byAdding: .year, value: -5, to: Date())!
        return date < minAgeDate
    }

    static func isNameFormValid(firstName: String, lastName: String, birthday: Date) -> Bool {
        return !firstName.isEmpty && !lastName.isEmpty && isBirthdayValid(birthday)
    }
    
    static func isEmailValid(_ email: String) -> Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    static func isLoginFormValid(email: String, password: String, confirmPassword: String) -> Bool {
        return !email.isEmpty &&
            !password.isEmpty &&
            !confirmPassword.isEmpty &&
            password == confirmPassword &&
            isEmailValid(email)
    }
}
