//
//  VehicleCardItem.swift
//  VehicleCardItem
//
//  Created by Leonardo Angeli on 08/09/21.
//

import SwiftUI

struct VehicleCardItem: View {
    
    @ObservedObject var vehicleVM: VehicleViewModel
    
    var vehicle: UserVehicle
    
    @Binding var animatedVehicleId: String?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VehiclePropertyDetails(vehicleViewModel: vehicleVM, vehicle: vehicle, geometry: geometry)
                    .transition(.opacity)
                    .frame(maxHeight: 450)
            }
            .padding()
            .background(BlurView(style: .systemChromeMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(animatedVehicleId == vehicle.id ? 0.3 : 0.4), radius: animatedVehicleId == vehicle.id ? 7 : 2, x: 1, y: 1)
            .scaleEffect(animatedVehicleId == vehicle.id ? 1.1 : 1)
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: animatedVehicleId)
            .padding(.horizontal, 30)
            .padding(.top, 40)
            .padding(.bottom, 50)
        }
    }
}


struct VehicleCardItem_Previews: PreviewProvider {
    static var previews: some View {
        VehicleCardItem(vehicleVM: VehicleViewModel(), vehicle: dummyUserVehicle, animatedVehicleId: .constant(nil))
    }
}
//currentVehicleId: .constant("hq24bbub2s")
