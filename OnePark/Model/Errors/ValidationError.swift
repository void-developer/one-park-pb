//
//  ValidationError.swift
//  ValidationError
//
//  Created by Leonardo Angeli on 06/09/21.
//

import SwiftUI

enum ValidationError: String {
    case missingRequiredField
    case fieldRequirementsNotMatching
    
    var localizedDescription: String {
        switch self {
            case .missingRequiredField:
                return "Please fill in all the required fields!"
            case .fieldRequirementsNotMatching:
                return "The field requirements are not matched!"
        }
    }
}
