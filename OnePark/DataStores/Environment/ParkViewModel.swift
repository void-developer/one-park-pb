//
//  ParkingViewModel.swift
//  ParkingViewModel
//
//  Created by Leonardo Angeli on 20/08/21.
//

import SwiftUI
import Firebase
import CoreLocation
import Lottie
import os

class ParkViewModel: ObservableObject {
    
    let auth = Auth.auth()
    
    private let logger = Logger(subsystem: "com.leoangeli.onepark", category: "ParkViewModel")
    
    init(sharingLocation: Bool = false) {
        self.sharingLocation = sharingLocation
        
        self.myParkUser = ParkingUser(latitude: 0, longitute: 0, userId: auth.currentUser?.uid ?? "", username: auth.currentUser?.displayName ?? "")
        //myParkUser.vehicleId = "MpI2ludCpYj6Qh0YZnBh"
    }
    
    @Published private(set) var sharingLocation: Bool
    
    var parkRepo: ParkRepository = ParkRepository(currentUserId: Auth.auth().currentUser?.uid ?? "")
    
    @Published var parkingModeUsers: [ParkingUser] = []
    @Published var offeringModeUsers: [ParkingUser] = []
    @Published var drivingTowardsUsers: [ParkingUser] = []
    
    @Published var destinationParkingSpot: ParkingUser?
    
    @Published var isHeadingTowardsParkingSpot: Bool = false
    @Published var isWaitingForParkingConfirmation: Bool = false
    @Published var hasDataChanged: Bool = false
    
    @Published var myParkUser: ParkingUser
    
    @Published var awaitingForConfirmationUser: ParkingUser?
    
    private var isUserDeletable: Bool = true
    
//    func fetchParkingUser(userId: String) -> ParkingUser? {
//        
//    }
    
    func addDestination(destinationUserId: String) {
        if let uid = auth.currentUser?.uid {
            parkRepo.addDestination(destinationUserId: destinationUserId, currentUserId: uid)
        }
    }
    
    func cancelDestination(destinationUserId: String) {
        if let uid = auth.currentUser?.uid,
            let destinationParkingSpot = destinationParkingSpot,
            destinationParkingSpot.userId == destinationUserId {
            parkRepo.removeDestination(destinationUserId: destinationUserId, currentUserId: uid)
            self.destinationParkingSpot = nil
        }
    }
    
    func addDrivingTowardsUser(parkingUser: ParkingUser, at: Int? = nil) {
        if let index = at {
            drivingTowardsUsers.insert(parkingUser, at: index)
        } else {
            drivingTowardsUsers.append(parkingUser)
        }
    }
    
    func removeDrivingTowardsUser(removedParkingUserId: String?, at: Int? = nil) {
        if let index = at ?? drivingTowardsUsers.firstIndex(where: {$0.userId == removedParkingUserId ?? ""}) {
            drivingTowardsUsers.remove(at: index)
        }
    }
    
    func replaceDrivingTowardsUser(changedParkingUserId: String?, at: Int? = nil, parkingUser: ParkingUser) {
        if let index = at ?? drivingTowardsUsers.firstIndex(where: {$0.userId == changedParkingUserId}) {
//            drivingTowardsUsers[index].distanceToDestination = changedValuesEntity.distance
//            drivingTowardsUsers[index].timeToDestination = changedValuesEntity.approxTime
            drivingTowardsUsers[index] = parkingUser
        } else {
            drivingTowardsUsers.append(parkingUser)
        }
    }
    
    func setCurrentVehicle(vehicleId: String) {
        DispatchQueue.main.async {
            self.myParkUser.vehicleId = vehicleId
        }
    }
    
    func setWaitingForUserConfirmation(awaiting: Bool = true, completion: @escaping (ApplicationError?) -> Void){
        if let destinationParkingSpot = destinationParkingSpot,
           let uid = auth.currentUser?.uid {
            if !awaiting {
                parkRepo.removeAwaitingUserFromDestination(oldDestination: destinationParkingSpot.userId, current: uid) { error in
                    if let _ = error {
                        completion(ApplicationError.notFound)
                    }
                }

            } else {
                parkRepo.addAwaitingForConfirmationUser(destinationUserId: destinationParkingSpot.userId, waitingUserId: uid) { error in
                    if let error = error {
                        switch error {
                            case .integrityConstraintViolated:
                                completion(ApplicationError.parkingSpotAlreadyTaken)
                            default:
                                completion(ApplicationError.genericError)
                        }
                        self.logger.error("[ParkViewModel] There has been an error while claiming the parking spot, error: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        self.isWaitingForParkingConfirmation = true
                    }
                    completion(nil)
                }
            }
        }
    }

    
    func update(currentLatitude: CLLocationDegrees, currentLongitude: CLLocationDegrees, approxTime: Double? = nil, distance: Double? = nil, completion: @escaping (ApplicationError?) -> Void) {
        
        myParkUser.latitude = currentLatitude
        myParkUser.longitude = currentLongitude
        myParkUser.timeToDestination = approxTime
        myParkUser.distanceToDestination = distance
        self.parkRepo.updateUserLocation(self.myParkUser) { error in
            if let _ = error {
                completion(ApplicationError.genericError)
            } else {
                completion(nil)
            }
        }
    }
    
    func confirmAwaitingUser(_ confirmedUserId: String, completion: @escaping (ApplicationError?) -> Void) {
        if let uid = auth.currentUser?.uid {
            DispatchQueue.main.async {
                //self.myParkUser.parkingMode = .none
                self.sharingLocation = false
                self.parkRepo.updateUserLocation(self.myParkUser) { error in
                    if let _ = error {
                        completion(ApplicationError.genericError)
                    } else {
                        completion(nil)
                    }
                }
            }
            
            //TODO: Make it a transaction block so that you cannot confirm someone that just canceled its arrival or everything will get messed up
            parkRepo.confirmAwaitingUser(currentUserId: uid, awaitingUserId: confirmedUserId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                do { try self.toggleFetch(parkingModeFilter: .none, fetching: false) } catch {print(error)}
            }
        }
    }
    
    func setParkingMode(_ parkingMode: ParkingMode) throws {
        logger.debug("Setting parking mode for user to \(parkingMode.rawValue)")
        guard let uid = auth.currentUser?.uid else {
            throw ApplicationError.unauthorized
        }
        
        sharingLocation = parkingMode != .none
        DispatchQueue.main.async {
            self.myParkUser.parkingMode = parkingMode
        }

        
        do {
            try parkRepo.setUserParkingMode(parkingMode, userId: uid)
        } catch { throw ApplicationError.notFound }
    }

    
    //######################################### iOS 15 ######################################//
    
    
    /// Sets the current user as awaiting user for the targeted parking spot.
    ///
    /// If the parking spot has contemporarly been taken by another user it will return an ApplicationError. If the awaiting parameter passed is set to false (the user no longer wants to be waiting for completion) then
    /// it will remove its own user id (only if it is his own userId) from the awaitingConfirmationUser property of the offering user
    /// - Throws
    ///     - `ApplicationError.parkingSpotAlreadyTaken`
    ///     if the offering user already has an awaiting user awaiting
    /// - Parameter awaiting: whether the user is going to await or not
    @available(iOS 15.0.0, *)
    func setWaitingForUserConfirmation(_ awaiting: Bool = true) async throws {
        if let destinationParkingSpot = destinationParkingSpot,
           let uid = auth.currentUser?.uid {
            logger.info("Adding/Removing awaiting user confirmation for user [id: \(destinationParkingSpot.userId)]")
            do {
                if !awaiting { try await parkRepo.removeAwaitingUserFromDestination(oldDestination: destinationParkingSpot.userId, current: uid) } else {
                    try await parkRepo.addAwaitingForConfirmationUser(destinationUserId: destinationParkingSpot.userId, waitingUserId: uid)
                }
                DispatchQueue.main.async {
                    self.isWaitingForParkingConfirmation = awaiting
                }
            } catch {
                logger.error("There has been an error while confirming arrival!")
                throw ApplicationError.parkingSpotAlreadyTaken
            }
        }
    }
    
    
    /// Confirms the currently waiting user
    ///
    ///
    /// Tries to confirm the currently waiting user to get the parking spot. During this time the user is NOT deletable as the cloud function need to evaluate the
    /// parking completion and assign correctly the points to the users (see `isUserDeletable`).
    ///
    /// Parking mode is set to none, and sharing mode is disabled.
    /// Once the user is confirmed all listeners are then removed
    /// - Parameter confirmedUserId: the user who is getting confirmed
    @MainActor
    @available(iOS 15.0.0, *)
    func confirmAwaitingUser(_ confirmedUserId: String) async throws {
        if let uid = auth.currentUser?.uid {
            logger.info("Confirming awaiting user with id \(confirmedUserId)...")
            self.isUserDeletable = false
            self.sharingLocation = false
            try await self.parkRepo.setUserParkingMode(.none, userId: uid)
            logger.debug("Set user parking mode to none!")
            self.parkRepo.confirmAwaitingUser(currentUserId: uid, awaitingUserId: confirmedUserId)
            logger.debug("Awaiting user is now confirmed!")
            try self.toggleFetch(parkingModeFilter: .none, fetching: false)
            //TODO: Make it a transaction block so that you cannot confirm someone that just canceled its arrival or everything will get messed up
        }
    }
    
    /// Updates the user's location (and that only). Location is intended as latitude, longitude and optional time and distance from a chosen destination (if chosen)
    ///
    /// If the destination is set the approxTime and distance MUST be present for the best user experience. A notification will be received by the offering user chosen as destination with
    /// the new user's arriving details such as time and distance from him
    /// - Parameters:
    ///   - currentLatitude: user's current latitude
    ///   - currentLongitude: user's current longitude
    ///   - approxTime: time to destination
    ///   - distance: distance from selected destination
    @available(iOS 15.0, *)
    func updateUserLocation(currentLatitude: CLLocationDegrees, currentLongitude: CLLocationDegrees, approxTime: Double? = nil, distance: Double? = nil) async throws {
        
        myParkUser.latitude = currentLatitude
        myParkUser.longitude = currentLongitude
        myParkUser.timeToDestination = approxTime
        myParkUser.distanceToDestination = distance

        Task.detached(priority: .background) {
            try await self.parkRepo.updateUserLocation(self.myParkUser)
        }
    }
    
    func delete() {
        if let uid = Auth.auth().currentUser?.uid,
            isUserDeletable {
            parkRepo.delete(userId: uid)
        }
    }

    
    
    /// Handles a newly added user event
    ///
    /// Handles a user added event fired. It adds the user to the parking users lists (offering or searching). If the user has parking mode it will just ignore it since it doesn't
    /// make any sense at that point.
    /// - Parameter parkingUser: the new parking user
    func handleNewUser(parkingUser: ParkingUser) {
        switch parkingUser.parkingMode {
            case .searching:
                self.parkingModeUsers.append(parkingUser)
                logger.trace("The parking user [username: \(parkingUser.username)] has been added to the searching users list")
            case .offering:
                self.offeringModeUsers.append(parkingUser)
                logger.trace("The parking user [username: \(parkingUser.username)] has been added to the offering users list")
            case .none:
                logger.warning("What the fuck are you even doing in here bro (new) [uid: \(parkingUser.userId)...")
        }
    }
    
    
    /// Handles the remove user event
    ///
    /// Handles a remove parking user event and proceeds to remvoe the user from its relative parking mode users list. If the user
    /// has none as parking spot it will try to remove it from both.
    /// - Parameter parkingUser: the removed parking user
    /// - Bug: When a user is confirming its parking spot its parking mode is set to none. This thing is not handled in here
    func handleRemovedUser(parkingUser: ParkingUser) {
        switch parkingUser.parkingMode {
            case .searching:
                if let index = parkingModeUsers.firstIndex(where: {$0.userId == parkingUser.userId}) {
                    self.parkingModeUsers.remove(at: index)
                }
            case .offering:
                if let index = offeringModeUsers.firstIndex(where: {$0.userId == parkingUser.userId}) {
                    self.offeringModeUsers.remove(at: index)
                }
                if destinationParkingSpot?.userId == parkingUser.userId {
                    destinationParkingSpot = nil
                }
            case .none:
                //TODO: Search in both lists to remove it (maybe refactoring the code in a better way)
                logger.warning("What the fuck are you even doing in here bro (old) [uid: \(parkingUser.userId)...")
        }
    }
    
    
    /// Starts a sharing session for the user. The user in order to start the session must have a valid vehicle selected
    ///
    /// The user must have selected a valid vehicle to be able to start the sharing session. (and duh has to be correctly logged in.
    /// It saves the user to the real time database with his chosen parkingMode
    ///
    /// Listeners are then added to the current user in the database (only in offering mode) to check for incoming users
    /// or awaiting for confirmation users and properly modify the published variables
    /// - Warning: This function does not disable the user sharing state in case of error. This must be handled by the caller
    /// - Throws
    ///     - `ApplicationError.vehicleNotSelected`
    ///     if the user has no valid selected vehicle
    ///     - `ApplicationError.unauthorized`
    ///     if the user is not correctly logged in (wierd)
    func startSharing(_ withOfferingListeners: Bool = false) throws {
        logger.debug("Starting sharing session for current user...")
        guard let _ = myParkUser.vehicleId else {
            logger.error("No vehicle is selected")
            throw ApplicationError.vehicleNotSelected
        }
        
        guard let uid = auth.currentUser?.uid else {
            logger.error("User is not authorized")
            throw ApplicationError.unauthorized
        }
        
        parkRepo.save(parkingUser: try initParkingUser())
        parkRepo.fetch(currentUserId: uid, handleNewUser: handleNewUser, handleRemovedUser: handleRemovedUser)
        if withOfferingListeners {
            logger.debug("User is in offering mode. Adding all listeners...")
            parkRepo.listenForIncomingUsers(
                currentUserId: uid,
                handleRemovedDTU: { [self] (rmPkU: String) in self.removeDrivingTowardsUser(removedParkingUserId: rmPkU)},
                handleChangedDTU: { [self] (rpPkUId: String, parkingUser: ParkingUser) in self.replaceDrivingTowardsUser(changedParkingUserId: rpPkUId, parkingUser: parkingUser)}
            )
            parkRepo.listenForConfirmationUsers(uid, handleNewAwaitingUser: { [self] (awaitingUserId: String?) in self.handleNewAwaitingConfirmationUser(awaitingUserId)})
        }
        logger.debug("Session correctly started!")
    }
    
    /// Stops the sharing session of the current user.
    ///
    /// Deletes the user from real time database, removes all the offering and searching users displayed on the user's map. Removes all current sharing features
    /// of the user (awaiting for confirmation user, destination parking spot).
    /// - Warning: This will lose all current progress with surronding community (such as users waiting for the current user)
    /// - Throws
    ///     - `ApplicationError.unauthorized`
    ///     if the user is not correctly logged in
    func stopSharing() throws {
        logger.debug("Stopping the current user sharing session...")
        guard let userId = auth.currentUser?.uid else {
            throw ApplicationError.unauthorized
        }
        parkRepo.unfetch()
        parkingModeUsers.removeAll()
        offeringModeUsers.removeAll()
        awaitingForConfirmationUser = nil
        isWaitingForParkingConfirmation = false
        sharingLocation = false
        myParkUser.parkingMode = .none
        if let destinationParkingSpot = destinationParkingSpot {
            cancelDestination(destinationUserId: destinationParkingSpot.userId)
        }
        if isUserDeletable {
            logger.debug("Deleting user from real time database...")
            parkRepo.delete(userId: userId)
        }
        logger.debug("Session correctly stopped!")
    }
    
    
    
    /// Toggles the current user sharing mode
    ///
    /// Activates/Deactivates the user sharing mode. It can optionally start listening for all the incoming users, awaiting for confirmation users and other driving/offering users around him.
    /// The users around him are filtered by the passed parking mode (ex. if 'offering' is passed then the user is not going to see the 'searching' users)
    /// - Parameters:
    ///   - parkingModeFilter: the filter to apply to surrounding users
    ///   - fetching: whether the user device should listen for data updates
    func toggleFetch(parkingModeFilter: ParkingMode = .offering, fetching: Bool = true, parkingMode: ParkingMode = .none) throws {
        if fetching {
            try startSharing(parkingMode == .offering)
        } else {
            try stopSharing()
        }
    }
    
    
    
    /// Sets the parkign mode for the current user
    ///
    /// The method executes also all the business logic behind the switching of the parking mode. If the parking mode is set to none, fetching stops, sharing location stops,
    /// the user record is deleted from the database. Other wise it will start the user sharing session (see: `startSharing()`)
    ///
    /// If the parking mode does not change from the current one, no action is performed
    /// - Throws
    ///     - `ApplicationError.notFound`
    ///     if the user is not found
    ///     - `ApplicationError.vehicleNotSelected`
    ///     if the user vehicle is not selected and the user is trying to start a session
    ///     - `ApplicationError.unauthorized`
    ///     if the user is not correctly logged in
    /// - Parameter parkingMode: new parking mode
    @available(iOS 15.0, *)
    func setParkingMode(_ parkingMode: ParkingMode) async throws {
        logger.debug("Setting parking mode for user to \(parkingMode.rawValue)")
        guard parkingMode != myParkUser.parkingMode else {
            return
        }
        
        guard let uid = auth.currentUser?.uid else {
            throw ApplicationError.unauthorized
        }
        
        sharingLocation = parkingMode != .none
        try toggleFetch(fetching: sharingLocation, parkingMode: parkingMode)
        
        await MainActor.run {
            myParkUser.parkingMode = parkingMode
        }
        
        
        do {
            try await parkRepo.setUserParkingMode(parkingMode, userId: uid)
        } catch { throw ApplicationError.notFound }
    }
    
    
    /// Initializes the current parking user
    ///
    /// A new parking user object is returned based on the current logged user. If not logged the method will throw an exception not returning anything
    /// - Throws
    ///     - `ApplicationError.unauthorized`
    ///     if the user is not logged in correctly
    /// - Returns: initialized parking user
    private func initParkingUser() throws -> ParkingUser {
        if let uid = auth.currentUser?.uid,
           let displayName = auth.currentUser?.displayName {
            logger.debug("Initializing parking user...")
            myParkUser.username = displayName
            myParkUser.userId = uid
            logger.debug("User is now set [username: \(self.myParkUser.username), uid: \(self.myParkUser.userId)]")
            return myParkUser
        }
        throw ApplicationError.unauthorized
    }
    
    
    /// Retrieves the parking user info
    ///
    /// Fetches the active user using the given userId and parking mode. The parking mode will be used to check
    /// either on one or the other list of active users separated by their parking mode
    /// - Throws
    ///     -  `ApplicationError.notFound`
    ///     if the parking user is not present within the selected list
    ///     - `ApplicationError.genericError`
    ///     if the parking mode passed is none
    /// - Parameters:
    ///   - userId: user id filter
    ///   - parkingMode: parking mode filter
    /// - Returns: parking user
    func getParkingUser(userId: String, parkingMode: ParkingMode) throws -> ParkingUser? {
        logger.debug("Searching selected user [id: \(userId)]...")
        var foundUser: ParkingUser?
        switch parkingMode {
            case .none:
                logger.warning("This is not supposed to happen")
                throw ApplicationError.genericError
            case .searching:
                foundUser = parkingModeUsers.first(where: {$0.userId == userId})
            case .offering:
                foundUser = offeringModeUsers.first(where: {$0.userId == userId})
        }
        
        guard let foundUser = foundUser else {
            logger.error("The user is nowhere to be found [id: \(userId)]")
            throw ApplicationError.notFound
        }
        
        logger.debug("The user has been found [id: \(userId), username: \(foundUser.username)]")
        return foundUser
    }
    
    /// Handles a new awaiting user event
    ///
    /// - Parameter awaitingUserId: awaiting user id
    func handleNewAwaitingConfirmationUser(_ awaitingUserId: String?) {
        if let awaitingUserId = awaitingUserId,
           let parkingUser = try? getParkingUser(userId: awaitingUserId, parkingMode: .searching) {
            logger.debug("New user is awaiting for confirmation! [id: \(awaitingUserId)")
            DispatchQueue.main.async {
                self.myParkUser.awaitingConfirmationUser = awaitingUserId
                self.awaitingForConfirmationUser = parkingUser
            }
        }
    }
}

