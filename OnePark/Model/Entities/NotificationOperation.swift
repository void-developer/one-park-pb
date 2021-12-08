//
//  NotificationOperationEntity.swift
//  NotificationOperationEntity
//
//  Created by Leonardo Angeli on 29/08/21.
//

import SwiftUI

struct NotificationOperation: Codable {
    var operation: String
    var notificationKeyName: String
    var notificationKey: String? = nil
    var registrationIds: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case operation
        case notificationKeyName = "notification_key_name"
        case notificationKey = "notification_key"
        case registrationIds = "registration_ids"
    }
    
//    init(operation: String, notificationKeyName: String, notificationKey: String, registrationIds: [String] = []) {
//        self.operation = operation
//        self.notificationKeyName = notificationKeyName
//        self.notificationKey = notificationKey
//        self.registrationIds = registrationIds
//    }
}
