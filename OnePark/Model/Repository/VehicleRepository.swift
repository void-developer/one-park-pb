//
//  VehicleRepository.swift
//  VehicleRepository
//
//  Created by Leonardo Angeli on 02/09/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct VehicleRepository {
    
    private let db = Firestore.firestore()
    
    func fetchUserVehicleInfo(userId: String, vehicleId: String, completion: @escaping (Result<UserVehicle, Error>) -> ()) {
        return db.collection("users/\(userId)/vehicles").document(vehicleId).getDocument { snapshot, error in
            if let error = error {
                print("[VehicleRepository] There was an error while retrieving the vehicle (id:\(vehicleId)) of the user (id:\(userId): ERROR: \(error)")
                completion(.failure(DataError.genericError))
            } else if let snapshot = snapshot {
                do {
                    let userVehicle: UserVehicle = try snapshot.data(as: UserVehicle.self)!
                    completion(.success(userVehicle))
                } catch {
                    print("[VehicleRepository] Could not decode the UserVehicle object when retrieving its info (carId: \(vehicleId)): ERROR: \(error)")
                    completion(.failure(DataError.nonExistingData))
                }
            } else {
                completion(.failure(DataError.nonExistingData))
            }
        }
    }
    
    
    @available(iOS 15.0.0, *)
    func fetchUserVehicleInfo(userId: String, vehicleId: String) async throws -> UserVehicle? {
        return await withCheckedContinuation({ continuation in
            db.collection("users/\(userId)/vehicles").document(vehicleId).getDocument { snapshot, error in
                if let error = error as? Never {
                    print("[VehicleRepository] There was an error while retrieving the vehicle (id:\(vehicleId)) of the user (id:\(userId): ERROR: \(error)")
                    continuation.resume(throwing: error)
                } else if let snapshot = snapshot {
                    let userVehicle: UserVehicle? = try? snapshot.data(as: UserVehicle.self)!
                    continuation.resume(returning: userVehicle)
                }
            }
        })
    }
    
    func fetchUserVehicles(userId: String, completion: @escaping (Result<[UserVehicle], Error>) -> ()) {
        return db.collection("users/\(userId)/vehicles").getDocuments { querySnapshot, error in
            if let error = error {
                print("[VehicleRepository] There was an error while retrieving the vehicles of user (id:\(userId): ERROR: \(error)")
                completion(.failure(DataError.genericError))
            } else if let querySnapshot = querySnapshot {
                do {
                    let userVehicles = try querySnapshot.documents.map({ (element) -> UserVehicle in
                        var userVehicle = try element.data(as: UserVehicle.self)!
                        userVehicle.id = element.documentID
                        return userVehicle
                    })
                    completion(.success(userVehicles))
                } catch {
                    print("[VehicleRepository] There has been an error while mapping the user vehicles: \(error)")
                    completion(.failure(DataError.nonExistingData))
                }
            } else {
                completion(.failure(DataError.nonExistingData))
            }
        }
    }
    
    @available(iOS 15.0.0, *)
    func fetchUserVehicles(userId: String) async throws -> [UserVehicle] {
        
        return await withCheckedContinuation({ continuation in
            db.collection("users/\(userId)/vehicles").getDocuments { querySnapshot, error in
                if let error = error as? Never {
                    print("[VehicleRepository] There was an error while retrieving the vehicles of user (id:\(userId): ERROR: \(error)")
                    continuation.resume(throwing: error)
                } else if let querySnapshot = querySnapshot {

                    let userVehicles = try? querySnapshot.documents.map({ (element) -> UserVehicle in
                        var userVehicle = try element.data(as: UserVehicle.self)!
                        userVehicle.id = element.documentID
                        return userVehicle
                    })
                    continuation.resume(returning: userVehicles ?? [])
                }
            }
        })
    }
    
    func fetchVehicleInfo(brand: String, model: String, vehicleType: String, completion: @escaping (Result<Vehicle, Error>) -> ()) {
        
        db.collection("vehicles/\(vehicleType)s/brands/\(brand)/models").document(model).getDocument { snapshot, error in
            if let error = error {
                print("[VehicleRepository] There was an error while retrieving the vehicle info (brand: \(brand), model: \(model), type: \(vehicleType)) -> ERROR: \(error)")
                completion(.failure(DataError.genericError))
            } else if let snapshot = snapshot {
                print(snapshot)
                do {
                    let vehicle: Vehicle? = try snapshot.data(as: Vehicle.self)
                    if let vehicle = vehicle {
                        completion(.success(vehicle))
                    } else {
                        completion(.failure(DataError.nonExistingData))
                    }
                } catch {
                    print("[VehicleRepository] Could not decode the UserCar object when retrieving its info (brand: \(brand), model: \(model), type: \(vehicleType)) -> ERROR: \(error)")
                    completion(.failure(DataError.nonExistingData))
                }
            }
        }
    }
    
    @available(iOS 15.0.0, *)
    func fetchVehicleInfo(brand: String, model: String, vehicleType: String) async throws -> Vehicle {
        return await withCheckedContinuation({ continuation in
            db.collection("vehicles/\(vehicleType)s/brands/\(brand)/models").document(model).getDocument { snapshot, error in
                if let error = error as? Never {
                    print("[VehicleRepository] There was an error while retrieving the vehicle info (brand: \(brand), model: \(model), type: \(vehicleType)) -> ERROR: \(error)")
                    continuation.resume(throwing: error)
                } else if let snapshot = snapshot {
                    let vehicle: Vehicle = try! snapshot.data(as: Vehicle.self)!
                    continuation.resume(returning: vehicle)
                }
            }
        })
    }
    
    
    func fetchVehiclesOptions(brand: String?, model: String?, vehicleType: String?, completion: @escaping (Result<[KeyValuePair], Error>) -> ()) {
        
        var collectionPath: String = "vehicles"
        if let vehicleType = vehicleType {
            collectionPath.append("/\(vehicleType)s/brands")
        }
        if let brand = brand {
            collectionPath.append("/\(brand)/models")
        }
        if let model = model {
            collectionPath.append("/\(model)")
        }
        
        db.collection(collectionPath).getDocuments { querySnapshot, error in
            if let error = error {
                print("[VehicleRepository] There was an error while retrieving the vehicles options: ERROR: \(error)")
                completion(.failure(DataError.genericError))
            } else if let querySnapshot = querySnapshot {
                let vehiclesOptions: [KeyValuePair] = querySnapshot.documents.map { elem in
                    KeyValuePair(key: elem.documentID, value: elem.data()["displayName"]! as! String)
                }
                completion(.success(vehiclesOptions))
            } else {
                completion(.failure(DataError.nonExistingData))
            }
        }
    }
    
    @available(iOS 15.0.0, *)
    func fetchVehiclesOptions(brand: String?, model: String?, vehicleType: String?) async throws -> [KeyValuePair] {
        
        var collectionPath: String = "vehicles"
        if let vehicleType = vehicleType {
            collectionPath.append("/\(vehicleType)s/brands")
        }
        if let brand = brand {
            collectionPath.append("/\(brand)/models")
        }
        if let model = model {
            collectionPath.append("/\(model)")
        }
        
        return await withCheckedContinuation({ continuation in
            db.collection(collectionPath).getDocuments { querySnapshot, error in
                if let error = error as? Never {
                    print("[VehicleRepository] There was an error while retrieving the vehicles options: ERROR: \(error)")
                    continuation.resume(throwing: error)
                } else if let querySnapshot = querySnapshot {
                    let vehiclesOptions: [KeyValuePair] = querySnapshot.documents.map { elem in
                        KeyValuePair(key: elem.documentID, value: elem.data()["displayName"] as? String ?? "ERROR")
                    }
                    continuation.resume(returning: vehiclesOptions)
                } else {
                    continuation.resume(returning: [])
                }
            }
        })
    }
    
    func saveUserVehicle(userVehicle: inout UserVehicle, userId: String, completion: @escaping (Error?) -> Void) {
        
        do {
            let documentReference = try db.collection("users/\(userId)/vehicles").addDocument(from: userVehicle) { error in
                completion(error)
            }
            print("Saved new vehicle with id \(documentReference.documentID)")
            userVehicle.id = documentReference.documentID
        } catch {
            print("[VehicleRepository] There was an error while saving the vehicle to the db, error: \(error)")
        }
    }
    
    
    @available(iOS 15.0.0, *)
    func saveUserVehicle(userVehicle: UserVehicle, userId: String) async throws -> UserVehicle {
        return await withCheckedContinuation({ continuation in
            let documentReference = try? db.collection("users/\(userId)/vehicles").addDocument(from: userVehicle) { error in
                if let error = error as? Never {
                    continuation.resume(throwing: error)
                }
            }
            print("Saved new vehicle with id \(documentReference?.documentID ?? "")")
            var savedVehicle = userVehicle
            savedVehicle.id = documentReference?.documentID ?? "ERROR_ID"
            continuation.resume(returning: savedVehicle)
        })
    }
    
    func deleteUserVehicle(userId: String, vehicleId: String, completion: @escaping (Error?) -> Void) {
        db.collection("users/\(userId)/vehicles").document(vehicleId).delete { error in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
    
    @available(iOS 15.0.0, *)
    func deleteUserVehicle(userId: String, vehicleId: String) async throws {
        return await withCheckedContinuation({ continuation in
            db.collection("users/\(userId)/vehicles").document(vehicleId).delete { error in
                if let error = error as? Never {
                    continuation.resume(throwing: error)
                }
                continuation.resume()
            }
        })
    }
}
