//
//  ViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//
import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView! // Connect to map view in Interface Builder or create programmatically
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Earthquake Map"
        
        // Load an empty map
        mapView.showsUserLocation = true
        mapView.showsTraffic = false
        mapView.showsScale = true
        mapView.showsCompass = true
    }
}
