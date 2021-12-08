//
//  ParkFinderMapView.swift
//  ParkFinderMapView
//
//  Created by Leonardo Angeli on 20/08/21.
//

import SwiftUI
import CoreLocation
import MapKit

struct ParkFinderMapView: View {

    //@EnvironmentObject var parkStore: ParkStore
    
    @State var userTrackingMode: MKUserTrackingMode = .none
    
    @Binding var shownAnnotation: MKAnnotation?
    @Binding var showCard: Bool
    
    var isMapCardView: Bool = false
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                MapView(userTrackingMode: $userTrackingMode, shownAnnotation: $shownAnnotation, showCard: $showCard)
                    .edgesIgnoringSafeArea(.all)
            
                
                VStack() {
                    HStack {
                        Spacer()
                        
                        Button(action: {userTrackingMode = userTrackingMode == .follow ? .none : .follow}) {
                            Image(systemName: "location.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .offset(x: -1, y: 1)
                        }
                        .frame(width: 45, height: 45, alignment: .center)
                        .background(BlurView(style: .systemChromeMaterial))
                        .clipShape(Circle())
                    }
                    .padding(.horizontal, 5)
                    .offset(y: -geometry.size.height/2 + (geometry.size.height < 500 ? geometry.size.height/4.8 : geometry.size.height/3.4))
                }
                
//                AnnotationCardView(showCard: $showCard, geometry: geometry, shownAnnotation: Binding(
//                    get: { shownAnnotation as? ParkAnnotation ?? dummyParkAnnotation }, set: { shownAnnotation = $0 }), isMapCardView: isMapCardView)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ParkFinderMapView_Previews: PreviewProvider {
    static var previews: some View {
        ParkFinderMapView(shownAnnotation: .constant(dummyParkAnnotation), showCard: .constant(true))
    }
}

let dummyParkAnnotation = ParkAnnotation(coordinate: CLLocationCoordinate2D(latitude: 42.0000, longitude: 12.000), title: "Available Parking Spot", subtitle: "Something", type: .offering, ownerId: "", ownerUsername: "helloWorldy")

