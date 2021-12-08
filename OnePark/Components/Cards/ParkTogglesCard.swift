//
//  ParkTogglesCardView.swift
//  ParkTogglesCardView
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI

struct ParkTogglesCard: View {
    
    var geometry: GeometryProxy
    
    
    @EnvironmentObject var parkStore: ParkViewModel
    
    @EnvironmentObject var applicationVM: ApplicationViewModel
    
    func handleParkingModeChange(_ parkingMode: ParkingMode) {
            if #available(iOS 15.0, *) {
                Task {
                    do { try await self.parkStore.setParkingMode(parkingMode) } catch { applicationVM.setApplicationError(error as NSError) }
                }
            } else {
                do { try parkStore.setParkingMode(parkingMode) } catch { applicationVM.setApplicationError(error as NSError) }
            }
    }
    
    var body: some View {
        
        let parkingBinding = Binding(
            get: {self.parkStore.myParkUser.parkingMode == .searching},
            set: {
                let parkingMode = $0 ? .searching :
                    (parkStore.myParkUser.parkingMode != .searching ? parkStore.myParkUser.parkingMode : .none)
                handleParkingModeChange(parkingMode)
            }
        )
        
        let offeringBinding = Binding(
            get: {self.parkStore.myParkUser.parkingMode == .offering},
            set: {
                let parkingMode = $0 ? .offering :
                (parkStore.myParkUser.parkingMode != .offering ? parkStore.myParkUser.parkingMode : .none)
                handleParkingModeChange(parkingMode)
            }
        )
        
        return HStack {
            HStack {
                VStack {
                    Toggle(isOn: parkingBinding) {
                        Text("Parking Mode")
                            .font(.system(.body, design: .rounded))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color("gradient2")))
                    
                    Toggle(isOn: offeringBinding) {
                        Text("Offering Mode")
                            .font(.system(.body, design: .rounded))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color("gradient2")))
                    
                }
                
            }
            .padding()
            .frame(maxWidth: geometry.size.width - 60, maxHeight: 150)
            .background(BlurView(style: .systemChromeMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal)
            .padding(.top, 20)
            
        }
        .onChange(of: parkStore.myParkUser.parkingMode) { newValue in
            print(newValue.rawValue)
        }
    }
}


struct ParkTogglesCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
        ParkTogglesCard(geometry: geometry)
                .environmentObject(ParkViewModel())
        }
    }
}
