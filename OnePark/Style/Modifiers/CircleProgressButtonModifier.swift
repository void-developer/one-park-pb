//
//  CircleProgressButton.swift
//  OnePark
//
//  Created by Leonardo on 18/08/21.
//

import SwiftUI

struct CircleProgressButtonModifier: ViewModifier {
    
    var baseButtonSize: CGFloat
    var buttonMinSize: CGFloat = 80
    var buttonMaxSize: CGFloat = 100
    
    var tap: Bool
    
    func body(content: Content) -> some View {
        content
            .frame(width: baseButtonSize, height: baseButtonSize)
            .frame(minWidth: buttonMinSize, maxWidth: buttonMaxSize, minHeight: buttonMinSize, maxHeight: buttonMaxSize)
            .background(
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.949164331, green: 0.9693112969, blue: 1, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    
                    Circle()
                        .stroke(Color.clear, lineWidth: 10)
                        .shadow(color: Color(#colorLiteral(red: 0.9032872319, green: 0.960066855, blue: 1, alpha: 1)), radius: 3, x: -5, y: -5)
                    Circle()
                        .stroke(Color.clear, lineWidth: 10)
                        .shadow(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), radius: 3, x: 3, y: 3)
                    
                }
            )
            .clipShape(Circle())
            .overlay(
                Circle()
                    .trim(from: tap ? 0.001 : 1, to: 1)
                    .stroke(LinearGradient(gradient: Gradient(colors: [Color("gradient1"), Color("gradient2")]), startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 5, lineCap:.round))
                    .rotationEffect(Angle(degrees: 90))
                    .rotation3DEffect(
                        Angle(degrees: 180),
                        axis: (x: 1, y: 0, z: 0.0)
                    )
                    .shadow(color: Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)).opacity(0.3), radius: 5, x: 3, y: 3)
                    .animation(Animation.easeInOut(duration: 0.2))
            )
            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).opacity(0.4), radius: 10, x: 5, y: 5)
    }
    
}

extension View {
    func circleProgressButton(baseButtonSize: CGFloat, buttonMinSize: CGFloat, buttonMaxSize: CGFloat, tap: Bool) -> ModifiedContent<Self, CircleProgressButtonModifier> {
        return modifier(CircleProgressButtonModifier(baseButtonSize: baseButtonSize, buttonMinSize: buttonMinSize, buttonMaxSize: buttonMaxSize, tap: tap))
  }
}
