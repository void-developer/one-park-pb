//
//  MapExtensions.swift
//  MapExtensions
//
//  Created by Leonardo Angeli on 01/09/21.
//

import SwiftUI
import MapKit

extension MKMapView {

    func zoomMap(byFactor delta: Double) {
        var region: MKCoordinateRegion = self.region
        var span: MKCoordinateSpan = self.region.span
        span.latitudeDelta *= delta
        span.longitudeDelta *= delta
        region.span = span
        self.setRegion(region, animated: true)
    }
    
    
    func setMapZoom(zoomFactor delta: Double, coordinate: CLLocationCoordinate2D? = nil) {
        var region: MKCoordinateRegion = self.region
        var span: MKCoordinateSpan = self.region.span
        span.latitudeDelta = delta
        span.longitudeDelta = delta
        region.span = span
        if let coordinate = coordinate {
            region.center = coordinate
        }
        self.setRegion(region, animated: true)
    }
}

