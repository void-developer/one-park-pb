//
//  UIResponsiveUtility.swift
//  OnePark
//
//  Created by Leonardo on 17/08/21.
//

import SwiftUI

func getAdditionalTopPadding(bounds: GeometryProxy) -> CGFloat {
    //print("Safe are insets are \(bounds.safeAreaInsets.top)")
    return bounds.safeAreaInsets.top > 22 ? bounds.safeAreaInsets.top : 0
}
