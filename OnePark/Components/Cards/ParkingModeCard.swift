//
//  ParkingModeCard.swift
//  ParkingModeCard
//
//  Created by Leonardo Angeli on 30/08/21.
//

import SwiftUI

struct ParkingModeCard: View {
    
    var geometry: GeometryProxy
    
    @State var parkingMode: ParkingMode = .offering
    @Binding var showCard: Bool
    @State var isAnimated: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                
                if showCard {
                    ZStack {
                        Image(systemName: "parkingsign.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color("gradient3"))
                            .scaleEffect(isAnimated ? 1 : 0.85)
                            .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimated)

                        
                        ForEach(0..<4) { index in
                            PulseCircle(index: index, animated: $isAnimated)
                        }
                    }
                    .onAppear {
                        isAnimated = true
                    }
                    .onDisappear {
                        isAnimated = false
                    }
                }
            }
            .frame(height: 100)
            .opacity(0.6)
            

            HStack {
                VStack(alignment: .leading) {
                    Text("Offering Mode Active")
                        .bold()
                    .font(.system(.title3, design: .rounded))
                    Text("Play a game or read an article while waiting for someone to accept your offer")
                        .font(.system(.caption, design: .rounded))
                }
                .padding(.leading, 10)
                .frame(maxWidth: (geometry.size.width - 60)/1.5)
                
                Spacer()
            }

        }
        .frame(maxWidth: geometry.size.width)
        .frame(height: 80)
        .background(Color("card1"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 30)

    }
}

struct PulseCircle: View {
    var index: Int
    @Binding var animated: Bool
    
    var body: some View {
        Circle()
            .stroke(Color("gradient3"), lineWidth: 10)
            .frame(width: 100, height: 100)
            .scaleEffect(animated ? 3.5 : 0.85)
            .opacity(animated ? 0 : 1)
            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: false).delay(0.5 + Double(index + 1)), value: animated)
            .offset(x: 0)

    }
}
