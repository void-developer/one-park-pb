//
//  ParkConfirmationCardView.swift
//  ParkConfirmationCardView
//
//  Created by Leonardo Angeli on 11/09/21.
//

import SwiftUI

struct ParkConfirmationCardView: View {
    
    @EnvironmentObject var parkVM: ParkViewModel
    @EnvironmentObject var applicationVM: ApplicationViewModel

    @Binding var parkingUser: ParkingUser
    
    @Binding var showCard: Bool
    
    var body: some View {
            VStack {
                
                Text("Woah!")
                    .bold()
                    .font(.system(.title, design: .rounded))
                
                Text("Looks like another user is waiting for your park confirmation!\n\nPlease check the information below and if it matches with the user claiming to be waiting.")
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.4)
                    .padding(10)
                    
                UserVehicleInfoView(parkingUser: $parkingUser)
                
                Button(action: {
                    withAnimation {
                        showCard = false
                    }
                    if #available(iOS 15.0.0, *) {
                        Task {
                            do {
                                try await parkVM.confirmAwaitingUser(parkingUser.userId)
                            } catch {applicationVM.setApplicationError(error as NSError)}
                        }
                    } else {
                        parkVM.confirmAwaitingUser(parkingUser.userId) { error in
                            if let error = error {
                                applicationVM.setApplicationError(error as NSError)
                            }
                        }
                    }
                }) {
                    Text("Confirm")
                        .bold()
                        .font(Font.custom("rubik", size: 25, relativeTo: Font.TextStyle.title3))
                        //.frame(maxWidth: geometry.size.width - 60, maxHeight: 60)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("gradient3"))
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .padding(.horizontal, 30)
                        .shadow(color: Color.black.opacity(0.4), radius: 3, x: 1, y: 1)

                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(.vertical, 20)
            .background(Color("bg2"))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color("shadow").opacity(0.3), radius: 2, x: 1, y: 1)
    }
}

struct ParkConfirmationCardView_Previews: PreviewProvider {
    static var previews: some View {
        ParkConfirmationCardView(parkingUser: .constant(dummyParkingUser), showCard: .constant(true))
            .environmentObject(UserViewModel())
            .environmentObject(ParkViewModel())
            .environmentObject(VehicleViewModel())
            .environmentObject(ApplicationViewModel())
    }
}
