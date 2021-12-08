//
//  BouncyButtonStyle.swift
//  BouncyButtonStyle
//
//  Created by Leonardo Angeli on 30/08/21.
//

import SwiftUI

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1)
            .animation(Animation.easeInOut, value: configuration.isPressed)
    }
}
