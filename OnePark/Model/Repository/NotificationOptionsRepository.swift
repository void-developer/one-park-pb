//
//  NotificationRepository.swift
//  NotificationRepository
//
//  Created by Leonardo Angeli on 29/08/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class NotificationOptionsRepository: ObservableObject {
    
    private let db = Firestore.firestore()
    
    private let userOptions = "userOptions"
    private let userCollectionPath: String = "users"
    private let notificationsPath: String = "notifications"
    
    func saveNotificationsOptions(userId: String, notificationOptions: NotificationOptions, merge: Bool) {
        do {
            try db.collection("\(userCollectionPath)/\(userId)/\(userOptions)").document("\(notificationsPath)").setData(from: notificationOptions)
        } catch {
            fatalError("Could not save the user options with the following uid \(userId) for: \(error.localizedDescription)")
        }
    }
    
    func addDeviceToken(userId: String, deviceToken: String, notificationKey: String? = nil) {
        do {
            try db.collection("\(userCollectionPath)/\(userId)/\(userOptions)").document("\(notificationsPath)").setData(from: NotificationOptions(notificationTokens: [deviceToken], notificationGroupKeyName: userId, notificationGroupKey: notificationKey), merge: true)
        } catch {
            fatalError("Could not save the user options with the following uid \(userId) for: \(error.localizedDescription)")
        }
    }
    
    func fetchNotificationOptions(userId: String) -> NotificationOptions? {

            var notificationOptions: NotificationOptions?
            db.collection("\(userCollectionPath)/\(userId)/\(userOptions)").document("\(notificationsPath)").getDocument(completion: { snapshot, error in
                if let error = error {
                    print("[NotificationOptionsRepository] There has been an error fetching the current NotificationOptions, ERROR: \(error)")
                } else {
                    do {
                        notificationOptions = try snapshot?.data(as: NotificationOptions.self)}
                    catch {
                        print("[NotificationsOptionsRepository] An error occured while decoding the notifications options, ERROR: \(error)")
                    }
                }
            })
            return notificationOptions

    }
}
