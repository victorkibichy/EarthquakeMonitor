//
//  ViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//


import UIKit

import MapKit

class MapViewController: UIViewController {
    var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Earthquakes History Map"
        
        setupMapView()
    }
    
    private func setupMapView() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        mapView.showsUserLocation = true
        mapView.showsTraffic = true
        mapView.showsScale = true
        mapView.showsCompass = true
    }
    
    override func loadView() {
        super.loadView()
        
        
    }
}
