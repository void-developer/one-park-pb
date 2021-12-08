//
//  AuthError.swift
//  AuthError
//
//  Created by Leonardo Angeli on 25/08/21.
//

import SwiftUI

enum AuthError: Error {
    case notAuthorized
    
    var localizedDescription: String {
        switch self {
        case .notAuthorized:
            return "The user is not authorized to acess this part of the application"
        }
    }
}
