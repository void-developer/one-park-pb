//
//  NotificationStore.swift
//  NotificationStore
//
//  Created by Leonardo Angeli on 26/08/21.
//

import SwiftUI
import FirebaseAuth
import FirebaseMessaging

class NotificationStore: ObservableObject {
    
    let auth = Auth.auth()
    let messaging = Messaging.messaging()
    
    @Published var notificationOptions: NotificationOptions = NotificationOptions()
    
    @Published var notificationList: [Notification] = []
    
    //@Published var notificationsPermission:
    
    private var notificationRepo: NotificationOptionsRepository = NotificationOptionsRepository()

    
    func addDeviceToken() {
        
            messaging.token { [self] token, error in
                if let error = error {
                    print("[NotificationStore] There has been an error while retreiving the token, error: \(error.localizedDescription)")
                } else {
                    if let userId = auth.currentUser?.uid,
                       let deviceToken = token {
                        

                        notificationRepo.addDeviceToken(userId: userId, deviceToken: deviceToken)

                    }
                }
            }
        
    }
    
    class func addDeviceToken() {
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("[NotificationStore] There has been an error while retreiving the token, error: \(error.localizedDescription)")
            } else {
                if let userId = Auth.auth().currentUser?.uid,
                   let deviceToken = token {
                    
                    NotificationOptionsRepository().addDeviceToken(userId: userId, deviceToken: deviceToken)

                }
            }
        }
        
    }
    
    func notificationKeyRequest(notificationKeyName: String, httpMethod: String = "GET", httpBody: Data? = nil) -> String? {
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/notification\(httpMethod == "GET" ? "?notification_key_name=\(notificationKeyName)" : "")") else { fatalError("Missing URL") }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = httpBody
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "Authorization")
        urlRequest.setValue(projectId, forHTTPHeaderField: "project_id")
        
        var notificationKey: String?
        
        print("Sending request to URL \(url.description), method \(String(describing: urlRequest.httpMethod)) and body \(String(describing: urlRequest.httpBody))")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 || ((response.statusCode == 201 || response.statusCode == 202)  && httpMethod == "POST") {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        notificationKey = try JSONDecoder().decode([String: String].self, from: data)["notification_key"]
                        print("The http request responded with notificationkey \(String(describing: notificationKey))")
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            } else {
                var errorMessage: String?
                
                do {
                    errorMessage = try JSONDecoder().decode([String: String].self, from: data!)["error"]
                } catch let error {
                    print("Error decoding: ", error)
                }
                print("Request to url \(url.description) failed with status code \(response.statusCode) and return message \(errorMessage ?? "")")
            }
        }

        dataTask.resume()
        return notificationKey
    }
//    
//    func fetch() {
//        notificationRepo.
//    }
//    
}
