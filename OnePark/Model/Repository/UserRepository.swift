//
//  UserRepository.swift
//  OnePark
//
//  Created by Leonardo on 17/08/21.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import os

class UserRepository: ObservableObject {

    private let userCollectionPath: String = "users"
    
    private let db = Firestore.firestore()
    
    let auth = Auth.auth()
    
    private let logger = Logger(subsystem: "com.leoangeli.onepark", category: "UserRepository")
    
    /// Saves the user to the database
    ///
    /// Saves the user to the database with the given info. As of right now it does not throws anything,
    /// but it will need oto be implemented
    /// - Parameter user: new user to be saved
    func save(user: UserPersonalInfo) {
        //TODO: Function needs to throws
        do {
            if let uid = auth.currentUser?.uid {
                try db.collection(userCollectionPath).document(uid).setData(from: user)
            }
        } catch {
            logger.error("There has been an error while saving the user [email: \(user.email)], error: \(error.localizedDescription)")
        }
    }
    
    /// Listens for user's info live changes
    ///
    /// Adds a listener for both local and server side changes on the user personal info. (see: `UserPersonalInfo`)
    /// - Parameters:
    ///   - userId: user id of the user to listen for
    ///   - handleChangeUserInfo: method handler for changes
    func listenForUserChanges(_ userId: String, handleChangeUserInfo: @escaping (UserPersonalInfo?) -> Void) {
        db.collection(userCollectionPath).document(userId).addSnapshotListener { [self] snapshot, error in
            if let error = error {
                logger.error("The user points have changed but there was an error while retrieving the new points! Error: \(String(describing: error))")
            } else {
                do { handleChangeUserInfo(try snapshot?.data(as: UserPersonalInfo.self)) } catch {
                    logger.error("The user retrieved from the listener cannot be decoded \(String(describing: error))")
                }
            }
        }
    }
    
    func fetch(email: String, completion: @escaping (Result<UserPersonalInfo, Error>) -> ()) {
        
        if let uid = auth.currentUser?.uid {
            let docRef = db.collection(userCollectionPath).document(uid)
            
            docRef.getDocument { (document, error) in

                let result = Result {
                    try document?.data(as: UserPersonalInfo.self)
                }
                
                switch result {
                case .success(let user):
                    if let user = user {
                        completion(.success(user))
                    } else {
                        self.logger.error("The user with email \(email) does not exist")
                        completion(.failure(DataError.nonExistingData))
                    }
                case .failure(let error):
                    self.logger.error("There has been an error while retrieving the user data, error: \(error.localizedDescription)")
                    self.logger.error("\(String(describing: error))")
                    completion(.failure(DataError.genericError))
                }
            }
        } else {
            completion(.failure(DataError.unauthorized))
        }
    }
    
}
