//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by Leonardo Angeli on 02/09/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Vehicle: Codable, Hashable {
    
    @DocumentID var id: String?
    
    var brand: String
    var model: String
    var image: UIImage?
    var length: Double
    var width: Double
    var height: Double
    var fuelType: FuelType
    var wheels: Int
    var vehicleType: VehicleType
    var displayBrand: String
    var displayModel: String
    
    enum CodingKeys: String, CodingKey {
        case brand
        case model
        case length
        case width
        case height
        case fuelType
        case wheels
        case vehicleType
        case displayBrand
        case displayModel = "displayName"
    }
    
}
