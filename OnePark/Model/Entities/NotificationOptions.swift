//
//  NotificationsOptions.swift
//  NotificationsOptions
//
//  Created by Leonardo Angeli on 29/08/21.
//

import SwiftUI

struct NotificationOptions: Codable {
    
    var notificationTokens: [String] = [String]()
    var notificationGroupKeyName: String?
    var notificationGroupKey: String?
    var isSubscribedToNewParkings: Bool = false
    var isSubscribedToIncomingUsers: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case notificationTokens
        case isSubscribedToNewParkings
        case isSubscribedToIncomingUsers
    }
}
