//
//  UserStore.swift
//  OnePark
//
//  Created by Leonardo on 17/08/21.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import os

class UserViewModel: ObservableObject {
    
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }

    @Published var userRepo = UserRepository()
    
    @Published var user: User
    
    private let logger = Logger(subsystem: "com.leoangeli.onepark", category: "UserViewModel")
    
    init(_ user: User = User(personalInfo: exampleUser)) {
        self.user = user
    }
    
    
    /// Fetches user basic info
    ///
    /// Fetches the user basic personal info. This method is to be used at startup or where checks on the user signing state
    /// have to be made. If the user is not signed in it will sign out of the app
    /// - Parameter email: user's email filter
    func fetch(email: String = Auth.auth().currentUser?.email ?? "") {
        //TODO: Revise the whole method
        if let uid = auth.currentUser?.uid {
            userRepo.fetch(email: email) { [self] result in
                switch result {
                case .success(let user):
                    self.user.personalInfo = user
                    try? addUserListener(uid)
                case .failure(let error):
                    switch error {
                        case DataError.nonExistingData:
                            logger.error("The user data does not exist, signing out...")
                            signedIn = false
                            try? Auth.auth().signOut()
                        default:
                            logger.error("Don't know what the heck happened, anyways here is the mysterious error \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func save() {
        userRepo.save(user: user.personalInfo)
    }
    
    //############################################# iOS 15 #################################################
    
    /// Self explainatory
    /// - Parameter points: new points
    func setPoints(_ points: Double) {
        user.personalInfo.points = points
    }
    
    /// Self explainatory
    /// - Parameter coins: new coins
    func setCoins(_ coins: Double) {
        user.personalInfo.coins = coins
    }
    
    
    /// Self explainatory
    /// - Parameter userInfo: new user info
    func setUserInfo(_ userInfo: UserPersonalInfo?) -> Void {
        if let userInfo = userInfo {
            user.personalInfo = userInfo
        }
    }
    
    /// Adds listener for user changes
    ///
    /// Adds listeners to firebase's user document for event changes. The entire user is going to be replaced by it
    /// - Throws
    ///     - `ApplicationError.unauthorized`
    ///     if the user is not correctly logged in
    /// - Parameter userId: user id to listen for
    func addUserListener(_ userId: String) throws {
        guard let uid = auth.currentUser?.uid else {
            throw ApplicationError.unauthorized
        }
        userRepo.listenForUserChanges(uid, handleChangeUserInfo: setUserInfo)
    }
}
