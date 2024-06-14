//
//  EarthquakeAnnotation.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/14/24.
//

import Foundation
import MapKit

class EarthquakeAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let magnitude: Double
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, magnitude: Double) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.magnitude = magnitude
    }
}
