//
//  SideNotesCard.swift
//  SideNotesCard
//
//  Created by Leonardo Angeli on 22/08/21.
//

import SwiftUI

struct SideNotesCard: View {
    
    var width: CGFloat?
    var height: CGFloat?
    
    var header: String
    @Binding var content: String
    
    @Binding var show: Bool
    
    @Binding var nsError: NSError?
    
    
    var body: some View {

        GeometryReader { geometry in
           
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(header)
                        .bold()
                        .font(.system(.title3, design: .rounded))
                    
                    Spacer()
                    
                    CloseButton(show: $show)
                }
                
                Text(nsError?.localizedDescription ?? content)
                    .font(.system(.body, design: .rounded))
            }
            .blurViewCard(height: height, width: width)
            .padding(.horizontal)
            .frame(minWidth: 0, minHeight: 0)
            .offset(x: show ? 0 : -geometry.size.width, y: 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
            
                
            
        }
        .frame(maxHeight: height ?? 400)
        .onChange(of: show) { newValue in
            if !newValue {
                content = ""
                nsError = nil
            }
        }

    }
}

struct SideNotesCard_Previews: PreviewProvider {
    static var previews: some View {
        SideNotesCard(height: 150, header: "This is a test sidenote ", content: .constant("This is just a test side note to check whether we have some problems within the card itself, I think this text is now enough, but what if it was not enought and I just keep on writing to the end of the days, what the heck is happening"), show: .constant(true), nsError: .constant(ApplicationError.parkingSpotAlreadyTaken as NSError))
    }
}
