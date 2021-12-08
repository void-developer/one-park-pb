//
//  ParkAnnotation.swift
//  ParkAnnotation
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI
import MapKit

class ParkAnnotation: MKPointAnnotation {

//  let coordinate: CLLocationCoordinate2D
//  let title: String?
//  let subtitle: String?
    var type: ParkingModeAnnotationType
    var ownerId: String
    var ownerUsername: String
    var reservedUserId: String?

    init(
        coordinate: CLLocationCoordinate2D,
        title: String,
        subtitle: String,
        type: ParkingModeAnnotationType,
        ownerId: String,
        ownerUsername: String
    ) {
        self.ownerId = ownerId
        self.type = type
        self.ownerUsername = ownerUsername
        super.init()
        super.coordinate = coordinate
        super.title = title
        super.subtitle = subtitle
    }
}
