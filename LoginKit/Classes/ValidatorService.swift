//
//  ValidatorService.swift
//  Pods
//
//  Created by Daniel Lozano Valdés on 1/4/17.
//
//

import Foundation
import Validator
import PhoneNumberKit


enum LoginValidationError: String, ValidationError {
    case invalidName = "Invalid name"
    case invalidUserName = "Invalid userName address"
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
        return isValidPhoneNumber(phoneNumber: input, phoneNumberKit: phoneNumberKit)
    }
    
    func isValidPhoneNumber(phoneNumber: String, phoneNumberKit: PhoneNumberKit) -> Bool {
        do {
            let _ = try phoneNumberKit.parse(phoneNumber, withRegion: PhoneNumberKit.defaultRegionCode(), ignoreType: false)
            return true
        } catch {
            return false
        }
    }
    
    public var error: ValidationError
    public typealias InputType = String
    let phoneNumberKit = PhoneNumberKit()

}
public struct NickNameRule: ValidationRule {
    public func validate(input: String?) -> Bool {
        guard let input = input, !input.isEmpty else { return false }
        
        let regexPattern = "^[a-zA-Z]+$"
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex?.numberOfMatches(in: input, options: [], range: NSRange(location: 0, length: input.count)) ?? 0
        
        return matches > 0
    }

    public var error: ValidationError
    public typealias InputType = String
}


struct ValidationService {

    static var userNameRules: ValidationRuleSet<String> {
        var userNameRules = ValidationRuleSet<String>()
        userNameRules.add(rule: PhoneNumberRule(error: LoginValidationError.invalidPhoneNumber))
        return userNameRules
    }

    static var passwordRules: ValidationRuleSet<String> {
        var passwordRules = ValidationRuleSet<String>()
        passwordRules.add(rule: ValidationRuleLength(min: 8,max: 12, error: LoginValidationError.passwordLength))
        return passwordRules
    }

    static var nameRules: ValidationRuleSet<String> {
        var nameRules = ValidationRuleSet<String>()
        nameRules.add(rule: ValidationRuleLength(min: 2,max: 12, error: LoginValidationError.passwordLength))
        nameRules.add(rule: NickNameRule(error: LoginValidationError.invalidName))
        return nameRules
    }
    



}
