//
//  UserVehicleInfoView.swift
//  UserVehicleInfoView
//
//  Created by Leonardo Angeli on 11/09/21.
//

import SwiftUI

struct UserVehicleInfoView: View {
    
    @EnvironmentObject var vehicleVM: VehicleViewModel
    @EnvironmentObject var applicationVM: ApplicationViewModel
    
    @Binding var parkingUser: ParkingUser
    @State var userVehicle: UserVehicle? = nil

    func updateVehicle() {
        if let vehicleId = parkingUser.vehicleId {
            
            if #available(iOS 15.0, *) {
                Task {
                    do {
                    self.userVehicle = try await vehicleVM.fetchUserVehicleInfo(userId: parkingUser.userId, vehicleId: vehicleId, detailed: true)
                    } catch { applicationVM.setApplicationError(error as NSError)}
                }
            } else {
                vehicleVM.fetchUserVehicleInfo(userId: parkingUser.userId, vehicleId: vehicleId, detailed: true) { result in
                    switch result {
                        case .success(let userVehicle):
                            self.userVehicle = userVehicle
                        case .failure(let error):
                            print(error)
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            if let userVehicle = userVehicle,
                let vehicle = userVehicle.fullVehicleInfo{
                UserVehicleInfoHeader(vehicle: vehicle, username: parkingUser.username)
            
                UserVehicleInfoSpecs(vehicle: vehicle, color: userVehicle.color)
               
                LicensePlate(licensePlate: userVehicle.plate)
                    .padding(.horizontal, 40)
                    .frame(height: 100)
            }
            
            
        }
        .padding(10)
        .padding(.top, 30)
        .padding(.horizontal, 10)
        .onAppear {
            updateVehicle()
        }
        
    }
}

struct UserVehicleInfoHeader: View {
    
    var vehicle: Vehicle?
    
    var username: String
    
    var body: some View {
        HStack {
            
            if let vehicleImage = vehicle?.image {
                Image(uiImage: vehicleImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300)
            } else {
                Image(systemName: "questionmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 150)
            }
            
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct UserVehicleInfoSpecs: View {
    
    var vehicle: Vehicle
    
    var color: String
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(spacing: 10) {
                Text("Width: \(vehicle.width.format(minimumFracionDigits: 0, maximumFractionDigits: 2))m")
                    .labelText()
                
                Text("Height: \(vehicle.height.format(minimumFracionDigits: 0, maximumFractionDigits: 2))m")
                    .labelText()
                
                Text("Length: \(vehicle.length.format(minimumFracionDigits: 0, maximumFractionDigits: 2))m")
                    .labelText()
            }
            .frame(height: 100)
            .frame(maxWidth: 400, maxHeight: 100, alignment: .center)
            .padding(3)
            .padding(.top, 5)
            .background(Color("light-gray").opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            
            VStack(spacing: 10) {
                Text("Brand: \(vehicle.displayBrand)")
                    .labelText()
                
                Text("Model: \(vehicle.displayModel)")
                    .labelText()
                
                HStack {
                    Text("Color: ")
                        .labelText()
                    Color(hex:
                            UInt(String(color.suffix(6)), radix: 16) ?? 0x90bf4e
                    )
                        .clipShape(Circle())
                        .frame(width: 20, height: 20)
                }
            }
            .frame(height: 100, alignment: .center)
            .frame(maxWidth: 200, maxHeight: 100, alignment: .center)
            .padding(3)
            .padding(.top, 5)
            .background(Color("light-gray").opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .padding(.vertical, 20)
    }
}


struct UserVehicleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        UserVehicleInfoView(parkingUser: .constant(dummyParkingUser), userVehicle: dummyUserVehicle)
            .environmentObject(VehicleViewModel())
            .environmentObject(ApplicationViewModel())
    }
}
