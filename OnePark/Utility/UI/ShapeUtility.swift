//
//  ShapeUtility.swift
//  ShapeUtility
//
//  Created by Leonardo Angeli on 21/08/21.
//

import SwiftUI

class ShapeUtility {
    
    
    class func getShape(shapeType: ShapeType, roundedRectangleCornerRadius: CGFloat = 20, roundedRectangleStyle: RoundedCornerStyle = .continuous) -> some Shape {
        switch shapeType {
        case .circle:
            return AnyShape(Circle())
        case .roundedRectangle:
            return AnyShape(RoundedRectangle(cornerRadius: roundedRectangleCornerRadius, style: roundedRectangleStyle))
            
        }
    }
}

struct AnyShape: Shape {
    init<S: Shape>(_ wrapped: S) {
        _path = { rect in
            let path = wrapped.path(in: rect)
            return path
        }
    }

    func path(in rect: CGRect) -> Path {
        return _path(rect)
    }

    private let _path: (CGRect) -> Path
}
