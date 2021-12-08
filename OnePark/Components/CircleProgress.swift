//
//  CircleProgress.swift
//  CircleProgress
//
//  Created by Leonardo Angeli on 31/08/21.
//

import SwiftUI

struct CircleProgress: View {
    
    @Binding var progress: Double
    
    var strokeWidth: CGFloat = 10
    
    var body: some View {
        Circle()
            .trim(from: 1 - progress)
            .stroke(LinearGradient(colors: [Color("gradient2"), Color("gradient1")], startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            .rotationEffect(Angle(degrees: 90))
            .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
            .background(Circle().stroke(Color.secondary.opacity(0.3),style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)))
            .animation(.easeInOut, value: progress)
    }
}

struct CircleProgress_Previews: PreviewProvider {
    static var previews: some View {
        CircleProgress(progress: .constant(0.7))
    }
}
