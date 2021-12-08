//
//  PasswordUtility.swift
//  PasswordUtility
//
//  Created by Leonardo Angeli on 21/08/21.
//

import SwiftUI
import Foundation

public class PasswordUtility {
    
    // Weak: F44336
    // medium: FFC108
    // good: 04A9F3
    // strog: 8BC34A
    class func setProgressView(strength: StrengthType) -> ProgressViewInformation {
        
        var progressStruct = ProgressViewInformation()
        
        switch strength {
        case .veryStrong:
            progressStruct.shouldValid = true
            progressStruct.percentage = 1.0
            progressStruct.color = PasswordRules.veryStrongStrengthColor
        case .strong:
            progressStruct.shouldValid = true
            progressStruct.percentage = 3/4
            progressStruct.color = PasswordRules.strongStrengthColor
        case .medium:
            progressStruct.shouldValid = false
            progressStruct.percentage = 2/4
            progressStruct.color = PasswordRules.mediumStrengthColor
        case .weak:
            progressStruct.shouldValid = false
            progressStruct.percentage = 1/4
            progressStruct.color = PasswordRules.weakStrengthColor
        case .veryWeak:
            progressStruct.shouldValid = false
            progressStruct.percentage = 0.01
            progressStruct.color = PasswordRules.weakStrengthColor
        }
        
        return progressStruct
    }
    
    
    class func checkValidationWithUniqueCharacter(pass: String, rules: [ValidationRequiredRule], minLength: Int, maxLength: Int, isUniqueCharRequired: Bool = PasswordRules.isUniqueCharRequired, passwordValidation: PasswordValidation) -> PasswordValidation {
        
        //let returnModel = PasswordValidation()
        let rule: [ValidationRequiredRule] = rules
        let minLength = minLength
        let maxLength = maxLength
        
        var validationCompletion: [ValidationRequiredRule] = []
        

        
        if pass.range(of: "[a-z]", options: .regularExpression, range: nil, locale: nil) != nil {
            validationCompletion.append(.lowerCase)
        }

        if pass.range(of: "[A-Z]", options: .regularExpression, range: nil, locale: nil) != nil {
            validationCompletion.append(.uppercase)
        }
        if pass.range(of: "[0-9]", options: .regularExpression, range: nil, locale: nil) != nil {
            validationCompletion.append(.digit)
        }
        
        if pass.range(of: "[!@#$&*]", options: .regularExpression, range: nil, locale: nil) != nil {
            validationCompletion.append(.specialCharacter)
        }
        
        if isUniqueCharRequired {
            if uniquecharacter(input: pass) == true {
                validationCompletion.append(.oneUniqueCharacter)
            }
        }
        
        
        if pass.count >= minLength {
            validationCompletion.append(.minimumLength)
        }
        
        if rule.count == validationCompletion.count {
            passwordValidation.allRequirementDone = true
        }

        
        
        passwordValidation.strength = strengthChecker(requiredRule: rule, containingRule: validationCompletion, minLength: minLength, maxLength: maxLength, currentLength: pass.count)
        passwordValidation.allRequirementDone = isRequiredRuleInputed(requiredRule: rule, containingRule: validationCompletion)
        passwordValidation.text = allRequirementCheck(requiredRule: rule, containingRule: validationCompletion,minimum: minLength)
        passwordValidation.progressView = setProgressView(strength: passwordValidation.strength)
        
        return passwordValidation
    }
    
    
    class func strengthChecker(requiredRule: [ValidationRequiredRule], containingRule: [ValidationRequiredRule], minLength: Int, maxLength: Int, currentLength: Int) -> StrengthType {
        
        if containingRule.count >= requiredRule.count {
            return .veryStrong
        } else if containingRule.count == requiredRule.count - 1 {
            return .strong
        } else if (containingRule.count > 1) && ( containingRule.count < requiredRule.count) {
            return .medium
        } else if containingRule.count == 1 && containingRule.count < requiredRule.count {
            return .weak
        } else {
            return .veryWeak
        }
    }
    
    
    class func isRequiredRuleInputed(requiredRule: [ValidationRequiredRule], containingRule: [ValidationRequiredRule]) -> Bool {
        
        var requirementFullFill: Bool = false
        if requiredRule.count == containingRule.count {
            requirementFullFill = true
        }
        
        return requirementFullFill
    }
    
    
    class func allRequirementCheck(requiredRule: [ValidationRequiredRule], containingRule: [ValidationRequiredRule], minimum: Int) -> String {
        
        var requiredString: String = ""
        
        for eachRule in requiredRule {
            switch eachRule {
            case .lowerCase:
                if containingRule.contains(eachRule) {
                    requiredString = ""
                } else {
                    requiredString = "The password requires at least a lowecase letter"
                    return requiredString
                }
                
            case .uppercase:
                if containingRule.contains(eachRule) {
                    requiredString = ""
                } else {
                    requiredString = "The password requires at least an uppercase letter"
                    return requiredString
                }
                
            case .digit:
                if containingRule.contains(eachRule) {
                    requiredString = ""
                } else {
                    requiredString = "The password requires at least a digit"
                    return requiredString
                }
                
            case .oneUniqueCharacter:
                if containingRule.contains(eachRule) {
                    requiredString = ""
                } else {
                    requiredString = "The password requires at least a unique character"
                    return requiredString
                }
                
            case .specialCharacter:
                if containingRule.contains(eachRule) {
                    requiredString = ""
                } else {
                    requiredString = "The password requires at least a special character from !@#$&* "
                    return requiredString
                }
            case .minimumLength:
                if containingRule.contains(eachRule) {
                    requiredString = ""
                } else {
                    requiredString = "The password must have at least \(minimum) characters"
                    return requiredString
                }
            case .passwordMismatch:
                if containingRule.contains(eachRule) {
                    requiredString = ""
                } else {
                    requiredString = "Passwords do not match!"
                    return requiredString
                }
            }
        }
        
        return requiredString
    }
    
    class func uniquecharacter(input: String) -> Bool {
        
        var isUnique: Bool = false
        var charac: [String] = []
        
        for item in input {
            charac.append("\(item)")
        }
        
        var counts: [String: Int] = [:]
        for character in charac {
            counts[character] = (counts[character] ?? 0) + 1
        }
        let nonRepeatingCharacters = charac.filter({counts[$0] == 1})
        
        if nonRepeatingCharacters.count > 0 {
            isUnique = true
        } else {
            isUnique = false
        }
        
        return isUnique
    }
    
}
