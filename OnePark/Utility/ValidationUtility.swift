//
//  ValidationUtility.swift
//  ValidationUtility
//
//  Created by Leonardo Angeli on 06/09/21.
//

import SwiftUI

struct ValidationUtility {
    
    public static func validateStrings(strings: [String?]) -> ValidationError? {
        for string in strings {
            if string == nil || string!.isEmpty {
                return ValidationError.missingRequiredField
            }
        }
        return nil
    }
    
    public static func validateString(string: String?, minLength: Int = 0, maxLength: Int = 1024) -> ValidationError? {
        guard string != nil else {
            return .missingRequiredField
        }
        return nil
    }
}
