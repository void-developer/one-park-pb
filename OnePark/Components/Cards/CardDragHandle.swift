//
//  CardDragHandle.swift
//  CardDragHandle
//
//  Created by Leonardo Angeli on 24/08/21.
//

import SwiftUI

struct CardDragHandle: View {
    
    @Binding var showCard: Bool
    @Binding var dragState: CGSize
    @Binding var showFullScreen: Bool
    
    var dismissHeight: CGFloat = 350
    var showFullScreenHeight: CGFloat = 100
    
    
    var body: some View {
        HStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(Color("background2"))
                .frame(width: 100, height: 7)
        }
        .frame(maxWidth: .infinity, maxHeight: 27, alignment: .center)
        .background(Color.black.opacity(0.001))
        .gesture(
            DragGesture().onChanged({ value in
                //print(value.translation.height)
                dragState = value.translation
            }).onEnded({ value in
                
                if value.translation.height > dismissHeight {
                    if !showFullScreen {
                        showCard = false
                    } else {
                        showFullScreen = false
                    }
                } else if value.translation.height < -showFullScreenHeight {
                    showFullScreen = true
                }
                dragState = .zero
            })
        )
    }
}

struct CardDragHandle_Previews: PreviewProvider {
    static var previews: some View {
        CardDragHandle(showCard: .constant(true), dragState: .constant(.zero), showFullScreen: .constant(false))
    }
}
