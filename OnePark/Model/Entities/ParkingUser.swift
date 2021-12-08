//
//  ParkingUser.swift
//  ParkingUser
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct ParkingUser: Codable, Identifiable, Hashable {
    
    
    @DocumentID public var id: String?
    var latitude: Double
    var longitude: Double
    var userId: String
    var username: String
    var isConfirmed: Bool
    var vehicleId: String?
    
    var parkingMode: ParkingMode = .none
    
    var distanceToDestination: Double? = 0
    var timeToDestination: Double? = 0

    var drivingTowardsUsersDict: [String]?
    var awaitingConfirmationUser: String?
    var currentVehicle: UserVehicle?
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case userId
        case parkingMode
        case timeToDestination = "approxTime"
        case distanceToDestination = "distance"
        case drivingTowardsUsersDict = "drivingTowardsUsers"
        case username
        case vehicleId
        case awaitingConfirmationUser
        case isConfirmed = "confirmed"
    }
    
    init(latitude: Double, longitute: Double, userId: String, parkingMode: ParkingMode = .none, username: String, timeToDestination: Double? = 0, distanceToDestination: Double? = 0, vehicleId: String? = nil, isConfirmed: Bool = false) {
        self.latitude = latitude
        self.longitude = longitute
        self.userId = userId
        self.parkingMode = parkingMode
        self.username = username
        self.timeToDestination = timeToDestination
        self.distanceToDestination = distanceToDestination
        self.vehicleId = vehicleId
        self.isConfirmed = isConfirmed
    }
    
    public static func == (lhs: ParkingUser, rhs: ParkingUser) -> Bool {
        return lhs.id == rhs.id
    }

}
