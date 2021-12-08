//
//  DataError.swift
//  DataError
//
//  Created by Leonardo Angeli on 20/08/21.
//

import SwiftUI

enum DataError: Error {
    
    case nonExistingData
    case genericError
    case unauthorized
    case integrityConstraintViolated
    
    var localizedDescription: String {
        switch self {
        case .nonExistingData:
            return "The data it's being retrieved does not EXIST!"
        case .unauthorized:
            return "The user does not have the correct rights to access such data"
        case .integrityConstraintViolated:
            return "An integrity constraint is being broken"
        case .genericError:
            return "There was some unexpected error while retrieving the data"
        }
    }
}
