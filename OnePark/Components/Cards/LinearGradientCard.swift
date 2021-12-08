//
//  LinearGradientCard.swift
//  LinearGradientCard
//
//  Created by Leonardo Angeli on 19/08/21.
//

import SwiftUI

struct LinearGradientCard: View {
    
    @State var didCardViewAppear: Bool = false
    
    var colors: [Color]
    var shadowColor: Color
    var rotationAngle: Double
    
    var animationDuration: Double = 3
    
    var forEverAnimated: Bool = true
    
    var width: Double = 900
    var height: Double = 600
    
    var offset: CGFloat = -100
    
    var shadowRadius: Double = 20
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .bottom, endPoint: .top)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style:.continuous))
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 0)
            .rotationEffect(Angle(degrees: rotationAngle))
            .rotation3DEffect(
                Angle(degrees: didCardViewAppear ? 10 : 0),
                axis: (x: 5, y: 5, z: 0)
            )
            .offset(y: offset)
            .animation(Animation.easeInOut)
            .onAppear {
                didCardViewAppear = true
            }
    }
}


struct LinearGradientCard_Previews: PreviewProvider {
    static var previews: some View {
        LinearGradientCard(colors: [Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)),Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))], shadowColor: Color(#colorLiteral(red: 0.3929225504, green: 0.5052531362, blue: 1, alpha: 1)), rotationAngle: 40, animationDuration: 10)
    }
}
