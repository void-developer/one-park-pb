//
//  OverlayProgressModifier.swift
//  OverlayProgressModifier
//
//  Created by Leonardo Angeli on 21/08/21.
//

import SwiftUI

struct OverlayProgressModifier: ViewModifier {
    
    var percentage: CGFloat
    
    var shapeType: ShapeType
    
    var colors: [Color]
    
    var rotationEffectAngle: Double
    var rotation3DEffectAngle: Double
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ShapeUtility.getShape(shapeType: shapeType)
                    .trim(from: 1 - percentage, to: 1)
                    .stroke(LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 5, lineCap:.round))
                    .rotationEffect(Angle(degrees: rotationEffectAngle))
                    .rotation3DEffect(
                        Angle(degrees: rotation3DEffectAngle),
                        axis: (x: 1, y: 0, z: 0.0)
                    )
                    .shadow(color: Color("gradient3").opacity(0.3), radius: 5, x: 3, y: 3)
                    .animation(Animation.easeInOut(duration: 0.2))
            )
            
    }
    
}

extension View {
    func progressShapeOverlay(progress: CGFloat, shapeType: ShapeType, colors: [Color] = [Color("gradient1"), Color("gradient2")], rotationEffectAngle: Double = 0, rotation3DEffectAngle: Double = 0) -> ModifiedContent<Self, OverlayProgressModifier> {
        return modifier(OverlayProgressModifier(percentage: progress, shapeType: shapeType, colors: colors, rotationEffectAngle: rotationEffectAngle, rotation3DEffectAngle: rotation3DEffectAngle))
  }
}
