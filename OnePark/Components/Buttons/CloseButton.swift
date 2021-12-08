//
//  CloseButton.swift
//  CloseButton
//
//  Created by Leonardo Angeli on 22/08/21.
//

import SwiftUI

struct CloseButton: View {
    
    @Binding var show: Bool
    
    var body: some View {
        Button(action: {show = false}) {
            Image(systemName: "xmark")
                .resizable()
                .foregroundColor(Color("primary"))
                .frame(width: 15, height: 15)
        }
        .frame(width: 35, height: 35)
        .background(Color("bg4-inv"))
        .clipShape(Circle())
    }
}

struct CloseButton_Previews: PreviewProvider {
    static var previews: some View {
        CloseButton(show: .constant(true))
            .preferredColorScheme(.dark)
    }
}
