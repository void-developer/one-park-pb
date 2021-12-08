//
//  UserCar.swift
//  UserCar
//
//  Created by Leonardo Angeli on 02/09/21.
//

import SwiftUI
import FirebaseFirestoreSwift

struct UserVehicle: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    
    var brand: String
    var model: String
    var color: String
    var plate: String
    var nickname: String
    var vehicleType: VehicleType
    var year: Int
    
    var fullVehicleInfo: Vehicle?
    
//    static func == (lhs: UserVehicle, rhs: UserVehicle) -> Bool {
//        return lhs.brand == rhs.brand && lhs.model == rhs.model && lhs.plate == rhs.plate
//    }
    
    enum CodingKeys: String, CodingKey {
        case brand
        case model
        case color
        case plate
        case nickname
        case vehicleType
        case year
    }
    
    func validate() -> String? {
        if(brand.isEmpty || model.isEmpty) {
            return "The brand and the model cannot be empty!"
        } else if (color.isEmpty) {
            return "The color of the vehicle cannot be empty!"
        } else if (nickname.isEmpty || nickname.count < 4 || nickname.count > 14) {
            return "The nickname of your vehicle can have a minimum of 4 letters and a maximum of 14!"
        } else if (year < 1950) {
            return "The vehicle cannot be older than 1950!"
        } else if (plate.isEmpty) {
            return "The plate of the vehicle cannot be empty!"
        }
        
        return nil
    }
    
    static func == (lhs: UserVehicle, rhs: UserVehicle) -> Bool {
        lhs.id == rhs.id
    }
}
