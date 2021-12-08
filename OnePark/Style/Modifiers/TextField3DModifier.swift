//
//  TextField3DModifier.swift
//  TextField3DModifier
//
//  Created by Leonardo Angeli on 19/08/21.
//

import SwiftUI


struct TextField3DModifier: ViewModifier {
    
    var maxWidth: CGFloat = 300
    var height: CGFloat = 55
    
    func body(content: Content) -> some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(Color.white)
                .blur(radius: 5)
                .offset(x: -3, y: -3)
            
            content
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 20)
            
        }
        .frame(maxWidth: maxWidth)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: Color.black.opacity(0.4), radius: 10, x:0 , y: 0)
        .shadow(color: Color(#colorLiteral(red: 0.7857586741, green: 0.864014864, blue: 1, alpha: 1)), radius: 5, x: 3, y: 3)
    
    }
}

extension View {
    func textField3DEffect(maxWidth: CGFloat, height: CGFloat) -> ModifiedContent<Self, TextField3DModifier> {
        return modifier(TextField3DModifier(maxWidth: maxWidth, height: height))
    }
    
    func textField3DEffect(maxWidth: CGFloat) -> ModifiedContent<Self, TextField3DModifier> {
        return modifier(TextField3DModifier(maxWidth: maxWidth))
    }
}

