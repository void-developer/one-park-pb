//
//  FieldCard.swift
//  FieldCard
//
//  Created by Leonardo Angeli on 01/09/21.
//

import SwiftUI

struct FieldCard: View {
    
    var body: some View {

        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: geometry.size.width/40, style: .continuous)
                    .foregroundColor(Color("light-purple"))
                .shadow(color: Color.black.opacity(0.4), radius: 3, x: 2, y: 2)
        }
    }
}

struct FieldCard_Previews: PreviewProvider {
    static var previews: some View {
        FieldCard()
            .padding()
    }
}
