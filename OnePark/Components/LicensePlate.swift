//
//  LicensePlate.swift
//  LicensePlate
//
//  Created by Leonardo Angeli on 04/09/21.
//

import SwiftUI

struct LicensePlate: View {
    
    var licensePlate: String
    
    @State var licensePlateHeight: CGFloat = 109
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: UIImage(imageLiteralResourceName: "license-plate"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text(licensePlate)
                    .font(.custom("bungee", size: geometry.size.width/6.5))
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                    .foregroundColor(Color("secondary"))
                    .padding(.leading, geometry.size.width/4.58)
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)//3.75
            }
            .frame(maxHeight: geometry.size.width/3.75)
            .frame(width: geometry.size.width)
            .onAppear {
                licensePlateHeight = geometry.size.width/3.75
            }
        }
        .frame(maxHeight: licensePlateHeight)
        
    }
    
}


struct LicensePlate_Previews: PreviewProvider {
    static var previews: some View {
        LicensePlate(licensePlate: "FK344FD")
    }
}
