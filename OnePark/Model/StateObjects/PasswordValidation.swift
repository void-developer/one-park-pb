//
//  PasswordValidation.swift
//  PasswordValidation
//
//  Created by Leonardo Angeli on 21/08/21.
//

import SwiftUI

class PasswordValidation: ObservableObject {
    var text: String = ""
    var identifier: Int = 0
    var constant: Float = 25.0
    var alpha: Float = 1.0
    var allRequirementDone: Bool = false
    var strength: StrengthType = .weak
    var progressView: ProgressViewInformation = ProgressViewInformation()
    var testString: String = ""
}


struct ProgressViewInformation {
    var color: UInt = 0x000000
    var percentage: CGFloat = 0.0
    var shouldValid: Bool = false
}
