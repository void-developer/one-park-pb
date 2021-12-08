//
//  MapView.swift
//  MapView
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @EnvironmentObject var parkStore: ParkViewModel
    @EnvironmentObject var userStore: UserViewModel
    
    @Binding var userTrackingMode: MKUserTrackingMode
    
    @Binding var shownAnnotation: MKAnnotation?
    @Binding var showCard: Bool
    
    @State var center: CLLocationCoordinate2D?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parkStore: parkStore, userStore: userStore, didPressOnAnnotation: didPressOnAnnotation)
    }
    
    func didPressOnAnnotation(_ annotation: MKAnnotation) {
        if let annotation = annotation as? ParkAnnotation {
            shownAnnotation = annotation
            showCard = true
        }
        center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
    }
    
    let manager = CLLocationManager()
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let map = MKMapView()
        
        manager.delegate = context.coordinator
        map.delegate = context.coordinator
        manager.startUpdatingLocation()
        map.setUserTrackingMode(userTrackingMode, animated: true)
        manager.requestAlwaysAuthorization()
        map.showsUserLocation = true
        map.register(ParkAnnotationView.self, forAnnotationViewWithReuseIdentifier: "User")
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        uiView.setUserTrackingMode(userTrackingMode, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(MapUtility.makeAnnotations(parkingUsers: parkStore.parkingModeUsers))
        uiView.addAnnotations(MapUtility.makeAnnotations(parkingUsers: parkStore.offeringModeUsers))
        if let center = self.center {
            uiView.setMapZoom(zoomFactor: 0.05, coordinate: center)
            DispatchQueue.main.async {
                self.center = nil
            }
        }
    }
}

class Coordinator: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var parkStore: ParkViewModel
    var userStore: UserViewModel
    
    var didPressOnAnnotation: (MKAnnotation) -> Void
    
    let directionsRequest: MKDirections.Request = MKDirections.Request()
    
    private var areDirectionsRequestable = true
    
    init(parkStore: ParkViewModel, userStore: UserViewModel, didPressOnAnnotation: @escaping (MKAnnotation) -> Void) {
        self.parkStore = parkStore
        self.didPressOnAnnotation = didPressOnAnnotation
        self.userStore = userStore
        super.init()
        
        directionsRequest.requestsAlternateRoutes = true
        directionsRequest.transportType = .automobile
    }
    
    func mapView(
      _ mapView: MKMapView,
      viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        if let annotation = annotation as? ParkAnnotation {
            let annotationView = ParkAnnotationView(
            annotation: annotation,
            reuseIdentifier: "User")
            if (parkStore.myParkUser.parkingMode == .searching) ^^ (annotation.type == .offering) {
                annotationView.image = UIImage(imageLiteralResourceName: "enemy-location-dot")
            }
            annotationView.canShowCallout = true
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
         didPressOnAnnotation(annotation)
            
        }
    }
      
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            print("Location services authorization has now been denied")
        case .restricted:
            print("The location services were restriced")
        case .notDetermined:
            print("Everything seems to work properly")
        case .authorizedAlways:
            print("Everything seems to work properly")
        case .authorizedWhenInUse:
            print("Everything seems to work properly")
        @unknown default:
            print("Everything seems to work properly")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let last = locations.last
        if parkStore.sharingLocation &&
            parkStore.myParkUser.parkingMode != ParkingMode.none,
            let coordinates = last?.coordinate {
    
 
            if areDirectionsRequestable,
               let destinationParkingSpot = parkStore.destinationParkingSpot{
                areDirectionsRequestable = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {self.areDirectionsRequestable = true})
                directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude), addressDictionary: nil))
                directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationParkingSpot.latitude, longitude: destinationParkingSpot.longitude), addressDictionary: nil))

                let directions = MKDirections(request: directionsRequest)

                
                directions.calculate { [self] (response, error) -> Void in
                    guard let response = response else {
                     if let error = error {
                         print("Error: \(error)")
                     }
                     return
                    }

                    if response.routes.count > 0 {
                        let route = response.routes[0]
                        let approxTime = route.expectedTravelTime
                        let distanceFromChosen = route.distance
                        parkStore.update(currentLatitude: coordinates.latitude, currentLongitude: coordinates.longitude, approxTime: approxTime, distance: distanceFromChosen) { error in
                            print(error?.localizedDescription ?? "")
                        }
                    }
                }
            } else {
                parkStore.update(currentLatitude: coordinates.latitude, currentLongitude: coordinates.longitude) { error in
                    print(error?.localizedDescription ?? "")
                }
            }

        }
    }
    
//    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
//        parkStore.delete()
//    }
//    
//    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
//        let last = manager.location
//        if parkStore.sharingLocation &&
//            parkStore.myParkUser.parkingMode != ParkingMode.none,
//            let coordinates = last?.coordinate {
//            
//            parkStore.save(currentLatitude: coordinates.latitude, currentLongitude: coordinates.longitude)
//    
//        }
//    }
}

