//
//  ParkModeAnnotationView.swift
//  ParkModeAnnotationView
//
//  Created by Leonardo Angeli on 23/08/21.
//

import SwiftUI

import MapKit

class ParkAnnotationView: MKAnnotationView {

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    guard
      let parkAnnotation = self.annotation as? ParkAnnotation else {
        return
    }
    
      image = parkAnnotation.type.image()
  }
}
