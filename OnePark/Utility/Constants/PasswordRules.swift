//
//  PasswordRules.swift
//  PasswordRules
//
//  Created by Leonardo Angeli on 21/08/21.
//

import SwiftUI

public class PasswordRules {
    public static var passwordRule : [ValidationRequiredRule] = [.lowerCase , .digit, .specialCharacter, .minimumLength, .uppercase]
    
    public static var weakStrengthColor : UInt = 0xF44336
    public static var mediumStrengthColor : UInt = 0xFFC108
    public static var strongStrengthColor : UInt = 0x04A9F3
    public static var veryStrongStrengthColor : UInt = 0x8BC34A
    
    public static var isUniqueCharRequired: Bool =  true
    public static var minPasswordLength : Int = 6
    public static var maxPasswordLength : Int = 20
}
