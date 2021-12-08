//
//  VehicleType.swift
//  VehicleType
//
//  Created by Leonardo Angeli on 02/09/21.
//

import SwiftUI

enum VehicleType: String, Codable, CaseIterable, Identifiable {
    case motorcycle
    case car
    case van
    
    var id: Self { self }
}
