//
//  BlurViewCardModifier.swift
//  BlurViewCardModifier
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI

struct BlurViewCardModifier: ViewModifier {

    var height: CGFloat?
    var width: CGFloat?
    
    var alignment: Alignment
    
    var opacity: Double
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, maxHeight: height ?? 400, alignment: alignment)
            .background(BlurView(style: .systemChromeMaterial).opacity(opacity))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(width: width)
            
    }
    
}

extension View {
    func blurViewCard(height: CGFloat? = nil, width: CGFloat? = nil, alignment: Alignment = .top, opacity: Double = 0.98) -> ModifiedContent<Self, BlurViewCardModifier> {
        return modifier(BlurViewCardModifier(height: height, width: width, alignment: alignment, opacity: opacity))
  }
}

//?? geometry.size.width - 30
