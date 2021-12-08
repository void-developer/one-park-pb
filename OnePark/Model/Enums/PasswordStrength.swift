//
//  PasswordStrength.swift
//  PasswordStrength
//
//  Created by Leonardo Angeli on 21/08/21.
//

import SwiftUI

enum StrengthType: String {
    case veryWeak
    case weak
    case medium
    case strong
    case veryStrong
}

public enum ValidationRequiredRule {
    case lowerCase
    case uppercase
    case digit
    case specialCharacter
    case oneUniqueCharacter
    case minimumLength
    case passwordMismatch
    
    static var allRules: [ValidationRequiredRule] = [.lowerCase, .uppercase, .digit, .specialCharacter, .oneUniqueCharacter, .minimumLength, .passwordMismatch]
}
