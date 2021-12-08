//
//  MapUtility.swift
//  MapUtility
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI
import MapKit

class MapUtility {

    class func makeAnnotations(parkingUsers: [ParkingUser]) -> [MKAnnotation] {
        var annotations: [MKAnnotation] = []
        
        //print("Making annotations...")
        for parkingUser in parkingUsers {
            annotations.append(ParkAnnotation(coordinate: CLLocationCoordinate2D(latitude: parkingUser.latitude, longitude: parkingUser.longitude), title: parkingUser.parkingMode.rawValue.capitalized, subtitle: "", type: ParkingModeAnnotationType.of(parkingUser.parkingMode), ownerId: parkingUser.userId, ownerUsername: parkingUser.username))
        }
        //print("Annotations finished, count is \(annotations.count)")
        return annotations
    }
}
