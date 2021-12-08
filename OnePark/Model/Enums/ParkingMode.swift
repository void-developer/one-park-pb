//
//  ParkingMode.swift
//  ParkingMode
//
//  Created by Leonardo Angeli on 20/08/21.
//

import SwiftUI

enum ParkingMode: String, Codable {
    case none
    case searching
    case offering
    
    static func of(_ parkingMode: ParkingModeAnnotationType) -> Self {
        switch parkingMode {
        case .none:
            return .none
        case .searching:
            return .searching
        case .offering:
            return .offering
        }
    }
}

enum ParkingModeAnnotationType: Int {
    case none = 0
    case searching
    case offering
    
    func image() -> UIImage {
      switch self {
      case .searching:
        return UIImage(imageLiteralResourceName: "_mapPin")
      case .offering:
          return UIImage(imageLiteralResourceName: "_mapPin")
      case .none:
          return UIImage(imageLiteralResourceName: "_mapPin")
      }
    }
    
    func image() -> Image {
      switch self {
      case .searching:
        return Image(systemName: "car")
      case .offering:
          return Image(systemName: "parkingsign.circle")
      case .none:
          return Image(systemName: "questionmark.circle")
      }
    }
    
    func description() -> String {
        switch self {
        case .searching:
            return "This poor man is looking for a parking spot, consider notifying other people you are leaving your parking spot and earn some extra points for your patience"
        case .offering:
            return "Quick this is an available parking spot, and it won't be for long! PRESS THE DAMN BUTTON!"
        case .none:
            return "Woah! This guy shouldn't be on the map"
        }
    }
    
    static func of(_ parkingMode: ParkingMode) -> Self {
        switch parkingMode {
        case .none:
            return .none
        case .searching:
            return .searching
        case .offering:
            return .offering
        }
    }
    
}
