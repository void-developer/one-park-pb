//
//  UserEntity.swift
//  OnePark
//
//  Created by Leonardo on 17/08/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct UserPersonalInfo: Codable {
    
    var firstName: String
    var lastName: String
    var email: String
    var username: String
    var phoneNumber: String
    var dob: Timestamp?
    var points: Double = 0
    var coins: Double = 0
    var sharedParkingSpotsToday: Int = 0
    var creationTS: Timestamp = Timestamp()
    var lastModifiedTS: Timestamp = Timestamp()
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case email
        case username
        case phoneNumber
        case points
        case coins
        case sharedParkingSpotsToday
        case creationTS
        case lastModifiedTS
    }

    mutating func setDOB(dob: Date) {
        self.dob = Timestamp(date: dob)
    }
    
    
    /// Validates the user's current info
    ///
    /// Uses the current values inside the user object and validates them. If any of the validation rules fail an error will be returned
    /// in the form of a string
    /// - Returns: descriptive error
    func validatePersonalInfo() -> String? {
        if(self.firstName.isEmpty || self.lastName.isEmpty || self.email.isEmpty || self.username.isEmpty || self.phoneNumber.isEmpty) {
            return "Please fill in all the required fields"
        } else if !self.email.isValidEmail {
            return "Please insert a valid email"
        } else if !self.phoneNumber.isValidPhoneNumber {
            return "Please insert a valid phone number. Be sure to include your country code, exapmle: +39"
        }
        return nil
    }
    
    func getCoins() -> Int {
        return Int(coins.rounded(.down))
    }
    
    func getPoints() -> Int {
        return Int(points.rounded(.down))
    }
}
