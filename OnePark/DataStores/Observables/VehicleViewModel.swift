//
//  CarViewModel.swift
//  CarViewModel
//
//  Created by Leonardo Angeli on 02/09/21.
//

import SwiftUI
import FirebaseAuth
import Contentful
import os

class VehicleViewModel: ObservableObject {
    
    let auth = Auth.auth()
    let client = Client(spaceId: contentfulSpaceId, accessToken: contentfulAccessToken)
    
    private let logger = Logger(subsystem: "com.leoangeli.onepark", category: "VehicleViewModel")
    
    @Published var personalVehicles: [UserVehicle] = []
    
    private let vehicleRepo: VehicleRepository = VehicleRepository()
    
    func fetchVehicleInfo(brand: String, model: String, vehicleType: VehicleType, completion: @escaping (Result<Vehicle, Error>) -> ()) {
        vehicleRepo.fetchVehicleInfo(brand: brand, model: model, vehicleType: vehicleType.rawValue) { result in
            switch result {
            case .success(var vehicle):
                    print("[VehicleViewModel] Info for vehicle {\(brand), \(model) and \(vehicleType.rawValue)} successfully retrieved!")
                self.fetchVehicleImage(brand: brand, model: model, completion: { uiImage in
                    print("[VehicleViewModel] Vehicle image fetched correctly! {\(brand), \(model)}")
                    vehicle.image = uiImage
                    completion(.success(vehicle))
                })
            case .failure(let error):
                print("[VehicleViewModel] Could not retrieve vehicle info {\(brand), \(model) and \(vehicleType.rawValue)}!")
                completion(.failure(error))
            }
        }
    }

    func fetchUserVehicleInfo(userId: String? = nil, vehicleId: String, detailed: Bool = false, completion: @escaping (Result<UserVehicle, Error>) -> ()) {
        guard let uid = userId ?? auth.currentUser?.uid  else {
            completion(.failure(DataError.unauthorized))
            return
        }
        
        vehicleRepo.fetchUserVehicleInfo(userId: uid, vehicleId: vehicleId) { [self] result in
            switch result {
            case .success(var vehicle):
                    if detailed {
                        fetchVehicleInfo(brand: vehicle.brand, model: vehicle.brand, vehicleType: vehicle.vehicleType, completion: { result in
                            switch result {
                                case .success(let vehicleInfo):
                                    vehicle.fullVehicleInfo = vehicleInfo
                                    completion(.success(vehicle))
                                case .failure(let error):
                                    completion(.failure(error))
                            }
                        })
                    }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchVehicleImage(brand: String, model: String, completion: @escaping (UIImage?) -> ()) {
        let query = Query.where(contentTypeId: vehicleContentTypeId)
                    .where(valueAtKeyPath: "fields.brand", .equals(brand.idString()))
                    .where(valueAtKeyPath: "fields.model", .equals(model.idString()))
        print("[VehicleViewModel] Fetching asset image through query: \(String(describing: query))")
        client.fetchArray(of: Entry.self, matching: query) { result in
            switch result {
                
            case .success(let array):
                guard array.items.count > 0,
                    let imageAsset = array.items[0].fields.linkedAsset(at: "image") else {
                    print("[VehicleViewModel] The vehicle was found but somehow there was no image...")
                    completion(nil)
                    return
                }
                
                self.client.fetchImage(for: imageAsset) { result in
                      switch result {
                      case .success(let image):
                          print("[VehicleViewModel] Image successfully retreiven {\(brand) - \(model)}")
                          completion(image)
                      case .failure(let error):
                          print("[VehicleViewModel] Error while retreiving the image for vehicle {\(brand) - \(model)}")
                          print(error)
                          completion(nil)
                      }
                }

            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }

    func fetchMyVehicles() {
        if let uid = auth.currentUser?.uid {
            vehicleRepo.fetchUserVehicles(userId: uid) { [self] result in
                switch result {
                    case .success(let vehicles):
                        print("[VehicleViewModel] Successfully retreived all vehicles {length: \(vehicles.count)}")
                        personalVehicles = vehicles
                        
                        for index in 0..<personalVehicles.count {
                            fetchVehicleInfo(brand: personalVehicles[index].brand, model: personalVehicles[index].model, vehicleType: personalVehicles[index].vehicleType) { result in
                                switch result {
                                    case .success(let fullVehicle):
                                        print("[VehicleViewModel] Full vehicle details for user vehicle successfully fetched")
                                        DispatchQueue.main.async {
                                            self.personalVehicles[index].fullVehicleInfo = fullVehicle
                                        }
                                    case .failure(let error):
                                        print("[VehicleViewModel] Could not retreive a detailed report of the user's vehicle... does it even exist?")
                                        print(error)
                                }
                            }
                        }
                        
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
    
    func fetchAllFullVehicles(brand: String? = nil, model: String? = nil, vehicleType: String? = nil, completion: @escaping ([KeyValuePair]) -> ()) {
        vehicleRepo.fetchVehiclesOptions(brand: brand, model: model, vehicleType: vehicleType) { result in
            switch result {
            case .success(let pairs):
                completion(pairs)
            case .failure(let error):
                print(error)
                completion([])
            }
        }
    }
    
    
    func saveUserVehicle(vehicle userVehicle: UserVehicle, completion: @escaping (Error?) -> Void) {
        print("[VehicleViewModel] Saving new vehicle {\(userVehicle.brand) - \(userVehicle.model) - PLATE: \(userVehicle.plate)}")
        if let uid = auth.currentUser?.uid {
            var newVehicle = userVehicle
            vehicleRepo.saveUserVehicle(userVehicle: &newVehicle, userId: uid) { [self] error in
                if error == nil {
                    print("[VehicleViewModel] Vehicle has successfully been saved! Retrieving in depth info... {\(userVehicle.plate)}")
                    self.fetchVehicleInfo(brand: newVehicle.brand, model: newVehicle.model, vehicleType: newVehicle.vehicleType, completion: { result in
                        switch result {
                            case .success(let fullVehicle):
                                print("[VehicleViewModel] All went through like a charm! Vehicle is being added to the personal vehicles list! {\(userVehicle.plate)}")
                                newVehicle.fullVehicleInfo = fullVehicle
                                DispatchQueue.main.async {
                                    personalVehicles.append(newVehicle)
                                }
                                completion(nil)
                            case .failure(let error):
                                print(error)
                                completion(error)
                        }
                    })
                }
                completion(error)
            }
        } else {
            completion(DataError.unauthorized)
        }
    }
    
    func deleteUserVehicle(userId: String? = nil, vehicleId: String) {
        if let uid = userId ?? auth.currentUser?.uid,
           let currentIndex = personalVehicles.firstIndex(where: {$0.id == vehicleId}) {
            print("[VehicleViewModel] Deleting new vehicle {\(uid) - \(vehicleId)}")
            vehicleRepo.deleteUserVehicle(userId: uid, vehicleId: vehicleId) { error in
                if let error = error {
                    print(error)
                } else {
                    print("[VehicleViewModel] Successfully deleted! {\(vehicleId)}")
                    self.personalVehicles.remove(at: currentIndex)
                }
            }
        }
    }
    
    
    //##################################### iOS 15 #############################################//
    
    /// Fetches full vehicle general info
    ///
    /// Fetches the specified vehicle info. This includes general vehicle specs and the image, which is retrieved from the contentful datamodel
    /// - Throws
    ///     - `ApplicationError.vehcileNotFound`
    ///     if some info of the vehicle could not be retrieved
    /// - Parameters:
    ///   - brand: vehicle's brand
    ///   - model: vehicle's model
    ///   - vehicleType: vehicle's type
    /// - Returns: full vehicle info
    @available(iOS 15.0.0, *)
    func fetchVehicleInfo(brand: String, model: String, vehicleType: VehicleType) async throws -> Vehicle {
        logger.debug("Fetching vehicle information (\(vehicleType.rawValue), brand: \(brand), model: \(model))...")
        async let image = try fetchVehicleImage(brand: brand, model: model)
        do {
            var vehicle = try await vehicleRepo.fetchVehicleInfo(brand: brand, model: model, vehicleType: vehicleType.rawValue)
            if let image = try await image {
                vehicle.image = image
            }
            logger.debug("Retrieved vehicle succesfully! [documentId: \(vehicle.id ?? "ERR")]")
            return vehicle
        } catch {
            logger.error("Failed to fetch vehicle information (\(vehicleType.rawValue), brand: \(brand), model: \(model))...")
            throw ApplicationError.vehicleNotFound
        }
    }

    /// Fetches all the vehicle information relative to the single user
    ///
    /// Fetches the information specific to the user vehicle and its full specifications (see `fetchVehicleInfo`). If the full spec sheet
    /// is not required for the operation, the `detailed` parameter can be set to false (no image nor spec sheet is returned)
    /// - Throws
    ///     - `ApplicationError.unauthorized`
    ///     if the user is not logged in correctly
    ///     - `ApplicationError.notFound`
    ///     if the vehicle id does not correspond to any existing data
    /// - Parameters:
    ///   - userId: vehicle's owner id
    ///   - vehicleId: vehicle id
    ///   - detailed: fetch or not the vehicle full spec sheet
    /// - Returns: user's vehicle
    @available(iOS 15.0.0, *)
    func fetchUserVehicleInfo(userId: String? = nil, vehicleId: String, detailed: Bool = false) async throws -> UserVehicle {
        logger.debug("Starting to retrieve the user vehicle info...")
        guard let uid = userId ?? auth.currentUser?.uid else {
            logger.error("The user is currently not logged in!")
            throw ApplicationError.unauthorized
        }
        guard var userVehicle = try await vehicleRepo.fetchUserVehicleInfo(userId: uid, vehicleId: vehicleId) else {
            logger.error("The user vehicle with id \(vehicleId) does not exist")
            throw ApplicationError.notFound
        }
        
        if detailed {
            userVehicle.fullVehicleInfo = try await fetchVehicleInfo(brand: userVehicle.brand, model: userVehicle.model, vehicleType: userVehicle.vehicleType)
        }
        return userVehicle
    }
    
    /// Fetches the currently logged in user's vehicles
    @available(iOS 15.0.0, *)
    func fetchMyVehicles() async throws {
        if let uid = auth.currentUser?.uid {
            self.personalVehicles = []
            let userVehicles = try await vehicleRepo.fetchUserVehicles(userId: uid)
            try await withThrowingTaskGroup(of: UserVehicle.self) { [self] group in
                for userVehicle in userVehicles {
                    group.addTask {
                        var personalVehicle = userVehicle
                        personalVehicle.fullVehicleInfo = try await fetchVehicleInfo(brand: userVehicle.brand, model: userVehicle.model, vehicleType: userVehicle.vehicleType)
                        return personalVehicle
                    }
                }
                for try await personalVehicle in group {
                    self.personalVehicles.append(personalVehicle)
                }
            }
        }
    }
    
    
    /// Fetches the vehicle subcategories options.
    ///
    /// Based on the given parameters it returnes a list of the least non-specified property, following the hierarchy
    /// * vehicleType > brand > model
    /// - Parameters:
    ///   - brand: brand filter
    ///   - model: model filter
    ///   - vehicleType: vehicleType filter
    /// - Returns: list of key value pair objects
    @available(iOS 15.0.0, *)
    func fetchAllFullVehicles(brand: String? = nil, model: String? = nil, vehicleType: String? = nil) async throws -> [KeyValuePair] {
        return try await vehicleRepo.fetchVehiclesOptions(brand: brand, model: model, vehicleType: vehicleType)
    }
    
    /// Saves a new user vehicle
    ///
    /// Saves the newly inserted vehicle from the user. If the saving operation goes through successfully it then proceeds
    /// to add the vehicle to the current user's vehicles avoiding heavy lifting for another download of the vehicles
    /// - Throws
    ///     - `ApplicationError.unauthorized`
    ///     if the user is not correctly logged in
    /// - Parameter userVehicle: new user vehicle
    @available(iOS 15.0.0, *)
    func saveUserVehicle(vehicle userVehicle: UserVehicle) async throws {
        logger.debug("Saving new vehicle {\(userVehicle.brand) - \(userVehicle.model) - PLATE: \(userVehicle.plate)}")
        guard let uid = auth.currentUser?.uid else { throw ApplicationError.unauthorized }
        async let vehicleInfo = self.fetchVehicleInfo(brand: userVehicle.brand, model: userVehicle.model, vehicleType: userVehicle.vehicleType)
        do {
            var newVehicle = try await vehicleRepo.saveUserVehicle(userVehicle: userVehicle, userId: uid)
            logger.debug("Saved! Not fetching the full vehicle info to add the vehicle to the user's list...")
            newVehicle.fullVehicleInfo = try await vehicleInfo
            let asyncVehicle = newVehicle
            DispatchQueue.main.async {
                self.personalVehicles.append(asyncVehicle)
            }
        } catch {
            throw ApplicationError.vehicleNotSaved
        }
    }

    /// Deletes the user personal vehicle
    ///
    /// Deletes the user's vehicle from the database
    /// - Throws
    ///     - `ApplicationError.unauthorized`
    ///     if the user is not logged in correctly
    ///     - `ApplicationError.vehicleNotFound`
    ///     if the vehicle could not be found in the user's personal vehicles
    /// - Parameters:
    ///   - userId: owner id
    ///   - vehicleId: vehicle id
    @available(iOS 15.0.0, *)
    func deleteUserVehicle(userId: String? = nil, vehicleId: String) async throws {
        guard let uid = auth.currentUser?.uid else { throw ApplicationError.unauthorized }
        logger.debug("Deleting the vehicle [id: \(vehicleId)] from the user's personal vehicles")
        async let vehicleIndex = personalVehicles.firstIndex(where: {$0.id == vehicleId})
        try await vehicleRepo.deleteUserVehicle(userId: uid, vehicleId: vehicleId)
        if let vehicleIndex = await vehicleIndex {
            DispatchQueue.main.async {
                self.personalVehicles.remove(at: vehicleIndex)
            }
        } else {
            logger.error("Could not find the vehicle belonging to user, perhaps it's already deleted")
            throw ApplicationError.vehicleNotFound
        }
        
    }
    
    
    /// Fetches the vehicle's image from contentful
    ///
    /// Retrieves the vehicle's image querying contenful data model (vehicleDataModel), through the given parameters:
    /// * brand
    /// * model
    /// - Parameters:
    ///   - brand: brand filter
    ///   - model: model filter
    /// - Returns: vehicles image
    @available(iOS 15.0.0, *)
    func fetchVehicleImage(brand: String, model: String) async throws -> UIImage? {
        let query = Query.where(contentTypeId: vehicleContentTypeId)
            .where(valueAtKeyPath: "fields.brand", .equals(brand.idString()))
            .where(valueAtKeyPath: "fields.model", .equals(model.idString()))
        logger.debug("Fetching asset image through query: \(String(describing: query))")
        
        return await withCheckedContinuation({ continuation in
            client.fetchArray(of: Entry.self, matching: query) { result in
                switch result {
                    case .success(let array):
                        guard array.items.count > 0,
                              let imageAsset = array.items[0].fields.linkedAsset(at: "image") else {
                                  self.logger.debug("The vehicle was found but somehow there was no image...")
                                  continuation.resume(returning: nil)
                                  return
                              }
                        
                        self.client.fetchImage(for: imageAsset) { result in
                            switch result {
                                case .success(let image):
                                    self.logger.debug("Image successfully retreiven {\(brand) - \(model)}")
                                    continuation.resume(returning: image)
                                case .failure(let error):
                                    self.logger.debug("Error while retreiving the image for vehicle {\(brand) - \(model)}")
                                    print(error)
                                    continuation.resume(returning: nil)
                            }
                        }
                        
                    case .failure(let error):
                        self.logger.debug("Error while retreiving the image for vehicle {\(brand) - \(model)}, error: \(error.localizedDescription)")
                        if let error = error as? Never {
                            continuation.resume(throwing: error)
                        }
                }
            }
        })
    }


}
