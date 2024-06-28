//
//  EarthquakeAnnotationView.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/14/24.
//

import MapKit

class EarthquakeAnnotationView: MKMarkerAnnotationView {
    static let identifier = "EarthquakeAnnotationView"

    override var annotation: MKAnnotation? {
        willSet {
            guard let earthquakeAnnotation = newValue as? MKPointAnnotation else { return }
            
            // Extract the magnitudeS from the title text
            
            let magnitudeString = earthquakeAnnotation.title?.replacingOccurrences(of: "Magnitude: ", with: "")
            let magnitude = Double(magnitudeString ?? "") ?? 0.0
            
            //  CUSTOM CONFIGURATIONS these are Configurations the marker's appearance based on the magnitude
            
            markerTintColor = getMarkerColor(forMagnitude: magnitude)
            glyphText = magnitudeString
            titleVisibility = .adaptive
            subtitleVisibility = .adaptive
        }
    }

    private func getMarkerColor(forMagnitude magnitude: Double) -> UIColor {
        switch magnitude {
        case ..<2.0:
            return .blue // Light earthquakes
        case 2.0..<4.0:
            return .green // Minor earthquakes
        case 4.0..<4.5:
            return .orange // Moderate earthquakes
        case 4.5..<7.0:
            return .red // Strong earthquakes
        case 7.0...:
            return .purple // Major earthquakes
        default:
            return .gray // Default color for unexpected values
        }
    }
}
