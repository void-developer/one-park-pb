//
//  Operators.swift
//  Operators
//
//  Created by Leonardo Angeli on 05/09/21.
//

import SwiftUI

infix operator *

func *(lhs: CGSize, rhs: Double) -> CGSize {
    return CGSize(width: lhs.width*rhs, height: lhs.height*rhs)
}

infix operator ^^

func ^^(lhs: Bool, rhs: Bool) -> Bool {
    return lhs != rhs
}

