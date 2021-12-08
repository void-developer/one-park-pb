//
//  LoadingAnimationView.swift
//  OnePark
//
//  Created by Leonardo on 16/08/21.
//

import SwiftUI

struct LoadingAnimationView: View {
    
    var componentWidth: CGFloat
    var componentHeight: CGFloat
    
    @State var didComponentLoad: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    LottieView(animation: "loadingAnimation")
                        .frame(width: componentWidth, height: componentHeight)
                }
                .padding(20)
                .background(BlurView(style: .systemMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.7), radius: 10, x: 0.0, y: 0.0)
                .scaleEffect(didComponentLoad ? 1 : 0)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black.opacity(0.4))
            .opacity(didComponentLoad ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))

        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            didComponentLoad = true
        }
        .onDisappear {
            didComponentLoad = false
        }
    }
}

struct LoadingAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingAnimationView(componentWidth: 200, componentHeight: 200)
    }
}
