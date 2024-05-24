//
//  ImageAnnotation.swift
//
//  Created by Tim Bachmann on 21.05.24
//

import Foundation
import UIKit
import MapKit

/**
 
 */
final class CustomPointAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    var id: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, id: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.id = id
    }
}
