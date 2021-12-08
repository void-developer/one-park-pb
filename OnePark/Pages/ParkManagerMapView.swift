//
//  ParkManagerMapView.swift
//  ParkManagerMapView
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI
import MapKit
struct ParkManagerMapView: View {
    
    @State var shownAnnotation: MKAnnotation?
    @State var showCard: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ParkFinderMapView(shownAnnotation: $shownAnnotation, showCard: $showCard)
                
                VStack {
                    Text("Park Manager")
                        .bold()
                        .font(.system(.title, design: .rounded))
                        .blurViewCard(height: 70, alignment: .center, opacity: 0.94)
                        .frame(maxWidth: geometry.size.width - 60)
                
                }
                .frame(height: geometry.size.height, alignment: .top)
                .frame(maxHeight: .infinity)

                AnnotationCardView(showCard: $showCard, shownAnnotation: Binding(
                    get: { shownAnnotation as? ParkAnnotation ?? dummyParkAnnotation }, set: { shownAnnotation = $0 }), isMapCardView: false)
                            
            }
        }
    }
}

struct ParkManagerMapView_Previews: PreviewProvider {
    static var previews: some View {
        ParkManagerMapView(shownAnnotation: dummyParkAnnotation, showCard: true)
            .environmentObject(ParkViewModel())
            .environmentObject(UserViewModel())
    }
}
