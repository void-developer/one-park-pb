//
//  BottomCardModifier.swift
//  BottomCardModifier
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI

struct BottomCardModifier: ViewModifier {

    var height: CGFloat
    var width: CGFloat
    
    var alignment: Alignment
    
    var opacity: Double
    
    @Binding var showCard: Bool
    
    @State var dragState: CGSize = .zero
    
    func body(content: Content) -> some View {
        VStack {
            
            HStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .foregroundColor(Color("background2"))
                    .frame(width: 100, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .gesture(
                DragGesture().onChanged({ value in
                    print("Helloooooo")
                    dragState = value.translation
                }).onEnded({ value in
                    if value.translation.height < height/2 {
                        showCard = false
                    }
                    dragState = .zero
                })
            )
            
            content
        }
        .frame(maxWidth: .infinity, maxHeight: height*2, alignment: alignment)
        .background(BlurView(style: .systemChromeMaterial).opacity(opacity))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .offset(y: showCard ? dragState.height + height : height)
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
            
    }
    
}

extension View {
    func bottomCardPopup(height: CGFloat = 400, width: CGFloat = 400, alignment: Alignment = .top, opacity: Double = 0.98, showCard: Binding<Bool>) -> ModifiedContent<Self, BottomCardModifier> {
        return modifier(BottomCardModifier(height: height, width: width, alignment: alignment, opacity: opacity, showCard: showCard))
  }
}
