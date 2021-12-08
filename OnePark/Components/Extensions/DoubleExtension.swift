//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by Leonardo Angeli on 31/08/21.
//

import SwiftUI

extension Double {
    func format(minimumFracionDigits: Int = 0, maximumFractionDigits: Int = 16) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = minimumFracionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return String(formatter.string(from: NSNumber(value: self)) ?? "")
    }
}
