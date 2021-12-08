//
//  LabelTextModifier.swift
//  LabelTextModifier
//
//  Created by Leonardo Angeli on 05/09/21.
//

import SwiftUI


struct LabelTextModifier: ViewModifier {

    var color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .lineLimit(1)
            .foregroundColor(color)
    }
}

extension View {
    func labelText(textColor color: Color = Color("secondary")) -> ModifiedContent<Self, LabelTextModifier> {
        return modifier(LabelTextModifier(color: color))
    }
}
