//
//  ValidatorService.swift
//  Pods
//
//  Created by Daniel Lozano Valdés on 1/4/17.
//
//

import Foundation
import Validator



enum LoginValidationError: String, ValidationError {
    case invalidName = "Invalid name"
    case invalidEmail = "Invalid email address"
    case passwordLength = "Must be at least 8 characters"
    case passwordNotEqual = "Password does not match"
    case invalidPhoneNumber = "Invalid phone number"
    var message: String {
        return self.rawValue
    }
    
    
}



public struct PhoneNumberRule: ValidationRule {
    public func validate(input: String?) -> Bool {
        guard let input = input else {return false}
        let phoneNumberRegex = "^[0-9]{10,15}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberPredicate.evaluate(with: input)
    }
    
    public var error: ValidationError
    public typealias InputType = String

}

public struct FullNameRule: ValidationRule {
    public func validate(input: String?) -> Bool {
        guard let input = input else {return false}
        let components = input.components(separatedBy: " ")
        guard components.count > 1 else {
            return false
        }

        guard let first = components.first, let last = components.last else {
            return false
        }

        guard first.characters.count > 1, last.characters.count > 1 else {
            return false
        }

        return true
    }
    
    public var error: ValidationError
    public typealias InputType = String

}


struct ValidationService {

    static var emailRules: ValidationRuleSet<String> {
        var emailRules = ValidationRuleSet<String>()
        emailRules.add(rule: ValidationRulePattern(pattern: EmailValidationPattern.standard,
                                                   error: LoginValidationError.invalidEmail))
        return emailRules
    }

    static var passwordRules: ValidationRuleSet<String> {
        var passwordRules = ValidationRuleSet<String>()
        passwordRules.add(rule: ValidationRuleLength(min: 8,max: 12, error: LoginValidationError.passwordLength))
        return passwordRules
    }

    static var nameRules: ValidationRuleSet<String> {
        var nameRules = ValidationRuleSet<String>()
        nameRules.add(rule: FullNameRule(error: LoginValidationError.invalidName))
        return nameRules
    }
    
    static var phoneRules: ValidationRuleSet<String> {
        var phoneRules = ValidationRuleSet<String>()
        phoneRules.add(rule: PhoneNumberRule(error: LoginValidationError.invalidPhoneNumber))
        return phoneRules
    }



}
