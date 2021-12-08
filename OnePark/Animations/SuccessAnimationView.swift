//
//  SuccessAnimationView.swift
//  SuccessAnimationView
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI

struct SuccessAnimationView: View {
    var componentWidth: CGFloat
    var componentHeight: CGFloat
    
    @State var didComponentLoad: Bool = false
    @Binding var disappearDelay: Bool
    
    var additionalOffset: CGFloat = 0
    
    var body: some View {
        VStack {

            LottieView(animation: "70085-success")
                .frame(width: componentWidth, height: componentHeight)
                .offset(y: additionalOffset)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
        .opacity(didComponentLoad ? 1 : 0)
        .animation(Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            didComponentLoad = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                disappearDelay = false
            }
        }
        .onDisappear {
            didComponentLoad = false
        }
    }
}

struct SuccessAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessAnimationView(componentWidth: 300, componentHeight: 300, disappearDelay: .constant(true))
    }
}
