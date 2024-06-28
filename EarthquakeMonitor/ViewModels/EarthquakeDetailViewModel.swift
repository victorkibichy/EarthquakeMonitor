//
//  EarthquakeDetailViewModel.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/26/24.
//

import Foundation
import CoreLocation

class EarthquakeDetailViewModel {
    private let earthquake: Earthquake
    
    // Expose a public getter to access the private earthquake property. thi sis because the earthquake data is universal for this [roject
    var earthquakeData: Earthquake {
        return earthquake
    }
    
    var magnitudeText: String {
        return "Magnitude: \(earthquake.magnitude)"
    }
    
    var placeText: String {
        return "Location: \(earthquake.place)"
    }
    
    var timeText: String {
        return "Time: \(DateFormatter.localizedString(from: earthquake.time, dateStyle: .medium, timeStyle: .short))"
    }
    
    var depthText: String {
        return earthquake.coordinates.count > 2 ? "Depth: \(earthquake.coordinates[2]) km" : "Depth: Unknown"
    }
    
    var coordinate: CLLocationCoordinate2D? {
        return earthquake.coordinates.count >= 2 ? CLLocationCoordinate2D(latitude: earthquake.coordinates[1], longitude: earthquake.coordinates[0]) : nil
    }
    
    var annotationTitle: String {
        return earthquake.place
    }
    
    init(earthquake: Earthquake) {
        self.earthquake = earthquake
    }
}
