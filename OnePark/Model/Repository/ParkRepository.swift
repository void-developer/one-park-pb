//
//  ParkRepository.swift
//  ParkRepository
//
//  Created by Leonardo Angeli on 20/08/21.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift
import CoreMedia

struct ParkRepository {
      
    var currentUserId: String
    var database: Database = Database.database(url: "https://onepark-d13b5-default-rtdb.europe-west1.firebasedatabase.app")
    
    var drivingTowardsRef: DatabaseReference! {
        database.reference(withPath: "users/\(currentUserId)/drivingTowardsUsers")
    }
    
    var currentUserRef: DatabaseReference! {
        database.reference(withPath: "users/\(currentUserId)")
    }
    var ref: DatabaseReference! {
        database.reference(withPath: "users")
    }
    
    init(currentUserId: String) {
        self.currentUserId = currentUserId
    }
    
    func save(parkingUser: ParkingUser) {
        
        currentUserRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            var currentDataValue: [String: AnyObject] = currentData.value as? [String: AnyObject] ?? [:]
            
            do {
                let newParkingUser = try JSONEncoder().encode(parkingUser)
                let dictionary = try JSONSerialization.jsonObject(with: newParkingUser, options: .allowFragments) as? [String: AnyObject]
                currentDataValue = dictionary ?? [:]
            } catch {
                print(error)
                TransactionResult.abort()
            }
            
            currentData.value = currentDataValue
            
            return TransactionResult.success(withValue: currentData)
        }) { error, committed, snapshot in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func addDestination(destinationUserId: String, currentUserId: String) {
        database.reference(withPath: "users/\(destinationUserId)").runTransactionBlock { currentData in
            if var destinationUser = currentData.value as? [String: AnyObject] {
                
                var currentDrivingTowardsUsersArray: [String] = destinationUser["drivingTowardsUsers"] as? [String] ?? [String]()
                currentDrivingTowardsUsersArray.append(currentUserId)
                
                destinationUser["drivingTowardsUsers"] = currentDrivingTowardsUsersArray as AnyObject
                currentData.value = destinationUser
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    func removeDestination(destinationUserId: String, currentUserId: String) {
        let ref = database.reference(withPath: "users/\(destinationUserId)/drivingTowardsUsers/\(currentUserId)")
        print("Removing data from \(ref)")
        ref.removeValue()
    }
    
    func delete(userId: String) {
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var userLocations = currentData.value as? [String: AnyObject] {
              // as? [String: AnyObject]
                print("Removing user location for id \(userId)...")
                userLocations.removeValue(forKey: userId)
                
                currentData.value = userLocations
                return TransactionResult.success(withValue: currentData)
            }
            
            return TransactionResult.success(withValue: currentData)
        }) { error, committed, snapshot in
            if let error = error {
                print(error.localizedDescription)
            } else if committed {
                print("User location of id \(userId) successfully removed!")
            }
        }
    }
    
    func fetch(currentUserId: String, parkingModeFilter: ParkingMode? = .offering, handleNewUser: @escaping (_ newUser: ParkingUser) -> Void, handleRemovedUser: @escaping (_ removedUser: ParkingUser) -> Void) {
        
        ref.observe(.childAdded) { snapshot in
            do {
                handleNewUser(try snapshot.data(as: ParkingUser.self))
            } catch {
                print(error)
            }
        }
        
        ref.observe(.childRemoved) { snapshot in
            do {
                handleRemovedUser(try snapshot.data(as: ParkingUser.self))
            } catch {
                print(error)
            }
        }
        
    }
    
    func unfetch() {
        ref.removeAllObservers()
    }
    
    func listenForIncomingUsers(currentUserId: String, handleRemovedDTU: @escaping (_ removedUserId: String) -> Void, handleChangedDTU: @escaping (_ changedUserId: String, _ parkingUser: ParkingUser) -> Void) {
        
        drivingTowardsRef.observe(.childAdded) { snapshot in
            if let newUserId = snapshot.value as? String {
                self.ref.child(newUserId).observe(.value) { userSnapshot in
                    do {
                        handleChangedDTU(newUserId, try userSnapshot.data(as: ParkingUser.self))
                        
                    } catch {
                        print("[ParkRepository] There has been a problem while retreiving \(newUserId) data, error: \(error)")
                    }
                    
                }
            }
        }
        
        drivingTowardsRef.observe(.childRemoved) { snapshot in
            if let removedUserId = snapshot.value as? String {
                handleRemovedDTU(removedUserId)
            }
        }
    }
    
    func addAwaitingForConfirmationUser(destinationUserId: String, waitingUserId: String, completion: @escaping (DataError?) -> Void) {
        ref.child(destinationUserId).runTransactionBlock { data in
            if var dataDict = data.value as? [String: AnyObject?] {
                
                if let _ = dataDict["awaitingConfirmationUser"] {
                    completion(DataError.integrityConstraintViolated)
                    return TransactionResult.success(withValue: data)
                }
                
                dataDict["awaitingConfirmationUser"] = waitingUserId as AnyObject
                data.value = dataDict
                completion(nil)
                return TransactionResult.success(withValue: data)
            }
            return TransactionResult.success(withValue: data)
        } andCompletionBlock: { error, committed, snapshot in
            if let _ = error {
                completion(DataError.genericError)
            } else if !committed {
                completion(DataError.integrityConstraintViolated)
            }
            completion(nil)
        }

    }

    func listenForConfirmationUsers(_ userId: String, handleNewAwaitingUser: @escaping (_ awaitingUserId: String?) -> Void) {
        ref.child("\(userId)/awaitingConfirmationUser").observe(.value) { snapshot in
            print("Child with key \(snapshot.key) added!")
            if snapshot.key == "awaitingConfirmationUser" {
                handleNewAwaitingUser(try? snapshot.data(as: String.self))
            }
        }
    }
    
    func confirmAwaitingUser(currentUserId uid: String, awaitingUserId waitingId: String) {
        ref.child("\(uid)/confirmed").setValue(true)
    }
    
    func updateUserLocation(_ parkingUser: ParkingUser, completion: @escaping (Error?) -> Void) {
        ref.child(parkingUser.userId).runTransactionBlock({ (data: MutableData) -> TransactionResult in
            if var dataDict = data.value as? [String: AnyObject] {
                dataDict[ParkingUser.CodingKeys.latitude.rawValue] = parkingUser.latitude as AnyObject
                dataDict[ParkingUser.CodingKeys.longitude.rawValue] = parkingUser.longitude as AnyObject
                dataDict[ParkingUser.CodingKeys.timeToDestination.rawValue] = parkingUser.timeToDestination as AnyObject
                dataDict[ParkingUser.CodingKeys.distanceToDestination.rawValue] = parkingUser.distanceToDestination as AnyObject
   
                data.value = dataDict
            }
            return TransactionResult.success(withValue: data)
        }) { error, committed, snapshot in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func removeAwaitingUserFromDestination(oldDestination destinationUserId: String, current currentUserId: String, completion: @escaping (DataError?) -> Void) {
        let awaitingConfirmationUserRef = ref.child(destinationUserId).child("awaitingConfirmationUser")
        awaitingConfirmationUserRef.getData(completion: { error, snapshot in
            if let _ = error {
                completion(DataError.genericError)
            } else if snapshot.value as? String == currentUserId {
                awaitingConfirmationUserRef.removeValue()
            } else {
                completion(DataError.nonExistingData)
            }
        })
    }
    
    func setUserParkingMode(_ parkingMode: ParkingMode, userId: String) throws {
        ref.child(userId).getData { error, snapshot in
            if snapshot.exists() {
                ref.child(userId).child(ParkingUser.CodingKeys.parkingMode.rawValue).setValue(parkingMode.rawValue)
            }
        }
    }

    //######################################### iOS 15 ######################################//
    
    @available(iOS 15.0.0, *)
    func addAwaitingForConfirmationUser(destinationUserId: String, waitingUserId: String) async throws {
        try await ref.child(destinationUserId).runTransactionBlock { data in
            if var dataDict = data.value as? [String: AnyObject?] {
                
                if let _ = dataDict["awaitingConfirmationUser"] {
                    return TransactionResult.abort()
                }
                
                dataDict["awaitingConfirmationUser"] = waitingUserId as AnyObject
                data.value = dataDict
                return TransactionResult.success(withValue: data)
            }
            return TransactionResult.success(withValue: data)
        }
    }
    
    @available(iOS 15.0.0, *)
    func updateUserLocation(_ parkingUser: ParkingUser) async throws {
        try await currentUserRef.runTransactionBlock { data in
            guard let dataValue = data.value else { return TransactionResult.abort() }
            if var dataDict = dataValue as? [String: AnyObject] {
                    
                dataDict[ParkingUser.CodingKeys.latitude.rawValue] = parkingUser.latitude as AnyObject
                dataDict[ParkingUser.CodingKeys.longitude.rawValue] = parkingUser.longitude as AnyObject
                dataDict[ParkingUser.CodingKeys.timeToDestination.rawValue] = parkingUser.timeToDestination as AnyObject
                dataDict[ParkingUser.CodingKeys.distanceToDestination.rawValue] = parkingUser.distanceToDestination as AnyObject
                
                data.value = dataDict as AnyObject

            }
            return TransactionResult.success(withValue: data)
        }
    }
    
    @available(iOS 15.0.0, *)
    func removeAwaitingUserFromDestination(oldDestination destinationUserId: String, current currentUserId: String) async throws {
        let awaitingConfirmationUserRef = ref.child(destinationUserId).child("awaitingConfirmationUser")
        do {
            let currentAwaitingUserId = try await awaitingConfirmationUserRef.getData().value
            if currentAwaitingUserId as? String == currentUserId {
                Task { awaitingConfirmationUserRef.removeValue() }
            }
        } catch {
            print("[ParkRepository] There has been an error while retrieving the awaitingConfirmationUser for user \(destinationUserId), error: ", error.localizedDescription)
            throw DataError.nonExistingData
        }
    }
    
    @available(iOS 15.0.0, *)
    func setUserParkingMode(_ parkingMode: ParkingMode, userId: String) async throws {
        let data = try await ref.child(userId).getData()
        if data.exists() {
            try await ref.child(userId).child(ParkingUser.CodingKeys.parkingMode.rawValue).setValue(parkingMode.rawValue)
        }
    }

}
