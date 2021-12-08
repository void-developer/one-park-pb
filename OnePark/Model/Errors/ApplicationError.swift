//
//  ApplicationError.swift
//  ApplicationError
//
//  Created by Leonardo Angeli on 11/09/21.
//

import SwiftUI

enum ApplicationError: Error {
    case genericError
    case parkingSpotAlreadyTaken
    case unauthorized
    case notFound
    case vehicleInUse
    case vehicleNotSelected
    case vehicleNotFound
    case vehicleNotSaved
}

extension ApplicationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .genericError:
                return NSLocalizedString("Something unexpected happened! That's a pity becaue neither do we, know how to fix this", comment: "")
            case .parkingSpotAlreadyTaken:
                return NSLocalizedString("TOO SLOW MAN! It seems this parking spot has just been taken. Next time just be faster", comment: "")
            case .unauthorized:
                return NSLocalizedString("Somehow we could not perform the action, looks like some authorization problem. If this is not supposed to happen try logging out and logging back in!", comment: "")
            case .notFound:
                return NSLocalizedString("We could not find what you were looking for. Perhaps it exists only in your immagination!", comment: "")
            case .vehicleInUse:
                return NSLocalizedString("The vehicle is currently selected. You cannot edit or delete the vehicle while parking/searching mode is active", comment: "")
            case .vehicleNotSelected:
                return NSLocalizedString("Please select a vehicle from your property manager to use during this session", comment: "")
            case .vehicleNotFound:
                return NSLocalizedString("Could not find the specified vehicle, probably a ghost or something like that!", comment: "")
            case .vehicleNotSaved:
                return NSLocalizedString("The vehicle you were trying to save could not be saved correctly", comment: "")
        }
    }
    
    public var failureReason: String? {
        switch self {
            case .genericError:
                return NSLocalizedString("Only god knows", comment: "")
            case .parkingSpotAlreadyTaken:
                return NSLocalizedString("Parking spot was already taken", comment: "")
            case .unauthorized:
                return NSLocalizedString("User is not signed in", comment: "")
            case .notFound:
                return NSLocalizedString("User is looking for something that was not found", comment: "")
            case .vehicleInUse:
                return NSLocalizedString("User tried to delete vehicle while in use", comment: "")
            case .vehicleNotSelected:
                return NSLocalizedString("You're trying to start a sharing session without selecting a vehicle", comment: "")
            case .vehicleNotFound:
                return NSLocalizedString("Data corruption on database", comment: "")
            case .vehicleNotSaved:
                return NSLocalizedString("Connection issues", comment: "")
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
            case .genericError:
                return NSLocalizedString("Just report it", comment: "")
            case .parkingSpotAlreadyTaken:
                return NSLocalizedString("Choose another parking spot, DUH!", comment: "")
            case .unauthorized:
                return NSLocalizedString("Try loggin out and back in", comment: "")
            case .notFound:
                return NSLocalizedString("Try reloading the app", comment: "")
            case .vehicleInUse:
                return NSLocalizedString("Disable the parking/offering mode to edit/delete the vehicle", comment: "")
            case .vehicleNotSelected:
                return NSLocalizedString("Select a vehicle from the property manager", comment: "")
            case .vehicleNotFound:
                return NSLocalizedString("RUN!", comment: "")
            case .vehicleNotSaved:
                return NSLocalizedString("Try resaving the vehicle or recreating it from scarp", comment: "")
        }
    }
}
