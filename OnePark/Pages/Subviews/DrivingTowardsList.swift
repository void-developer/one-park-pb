//
//  DrivingTowardsList.swift
//  DrivingTowardsList
//
//  Created by Leonardo Angeli on 30/08/21.
//

import SwiftUI

struct DrivingTowardsList: View {
    
    @EnvironmentObject private var parkViewModel: ParkViewModel
    
    var body: some View {
        
        return List {
            ForEach(parkViewModel.drivingTowardsUsers) { user in
                HStack {
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 45, height: 45)
                    
                    VStack(alignment: .leading) {
                        Text(user.username)
                            .bold()
                            .font(.system(.body, design: .rounded))
                        Text("ID: \(user.userId)")
                            .font(.system(.caption, design: .rounded))
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    Text("\((user.distanceToDestination ?? 0).format(minimumFracionDigits: 0, maximumFractionDigits: 2))m")
                        .font(.system(.caption, design: .rounded))
                        .padding(.trailing, 5)
                    
                    CircleProgress(progress: Binding(
                        get: { 1 - (user.timeToDestination ?? 0)/180 }, set: { _ in print("Cannot set") }), strokeWidth: 5)
                        .frame(width: 35, height: 35)
                        .overlay(Text("\((user.timeToDestination ?? 0).format(minimumFracionDigits: 0, maximumFractionDigits: 0))s"))
                            .font(.system(.caption2, design: .rounded))
                }
                .frame(maxHeight: 70)
            }
        }
    }
}

struct DrivingTowardsList_Previews: PreviewProvider {
    static var previews: some View {
        
        let parkStore: ParkViewModel = ParkViewModel()
        parkStore.drivingTowardsUsers = testUsers
        return DrivingTowardsList()
            .environmentObject(parkStore)
    }
}

let testUsers = [
    ParkingUser(latitude: 32.000, longitute: 32.000, userId: "Something", username: "dudeNumber1", timeToDestination: 30, distanceToDestination: 800),
    ParkingUser(latitude: 32.000, longitute: 32.000, userId: "Someone", username: "dudeNumber2", timeToDestination: 120, distanceToDestination: 600),
    ParkingUser(latitude: 32.000, longitute: 32.000, userId: "Someone Else", username: "girlNumber1", timeToDestination: 42, distanceToDestination: 1200),
    ParkingUser(latitude: 32.000, longitute: 32.000, userId: "Somewhat Someone", username: "girlNumber3", timeToDestination: 19, distanceToDestination: 2000)
]
