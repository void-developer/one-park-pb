//
//  CardFieldModifier.swift
//  CardFieldModifier
//
//  Created by Leonardo Angeli on 04/09/21.
//

import SwiftUI

struct CardFieldModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .foregroundColor(Color("secondary"))
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("bg2"))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .shadow(color: Color("shadow").opacity(0.5), radius: 2, x: 1, y: 1)
    }
}


extension View {
    func cardField() -> ModifiedContent<Self, CardFieldModifier> {
        return modifier(CardFieldModifier())
    }
}
