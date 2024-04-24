//
//  UserAuthViewModel.swift
//  Medbook
//
//  Created by Harshit Srivastava on 14/04/24.
//

import Foundation

@MainActor
class UserAuthViewModel: ObservableObject {
    
    @Published var isLengthValid: Bool = false
    @Published var isUppercaseValid: Bool = false
    @Published var isSpecialCharValid: Bool = false
    @Published var isValidEmail: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var country: String = ""
    @Published var code: String = ""
    @Published var isUserReadyToSignUp: Bool = false
    @Published var defaultCountry: String?
    @Published var isShowingDetailView: Bool = false
    
    func validateUserSignupState() {
        isLengthValid = password.count >= 8
        isUppercaseValid = password.contains { $0.isUppercase }
        isSpecialCharValid = password.contains { "!@#$&*%^?".contains($0) }
        isUserReadyToSignUp = isLengthValid && isUppercaseValid && isSpecialCharValid
    }
    
    func isValidEmailFormat(_ email: String) {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isValidEmail = emailPredicate.evaluate(with: email)
    }
    
}
