//
//  MapViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    var mapView: MKMapView!
    private var earthquakes: [Earthquake] = []
    private var mapTypeSegmentedControl: UISegmentedControl!
    private var compassButton: MKCompassButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Earthquakes History"
        
        setupMapView()
        setupMapControls() // Setup map controls for map type and compass
        fetchEarthquakeData() // Fetch and display earthquake data on map
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
    
    private func setupMapControls() {
        // Map type segmented control
        mapTypeSegmentedControl = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
        mapTypeSegmentedControl.selectedSegmentIndex = 0 // Default to standard map type
        mapTypeSegmentedControl.addTarget(self, action: #selector(mapTypeChanged(_:)), for: .valueChanged)
        navigationItem.titleView = mapTypeSegmentedControl
        
        // Compass button
        compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible // Always show compass
        mapView.addSubview(compassButton)
    }
//     THE TOP TOGGLE BUTTONS TO SWITCH TO DIFFERENT MAP TYPES
    
    @objc private func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            break
        }
    }
    
    
    private func fetchEarthquakeData() {
        guard let url = URL(string: "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2022-01-01&endtime=2022-01-02") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Failed to fetch earthquake data:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let earthquakeResponse = try decoder.decode(EarthquakeResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self?.earthquakes = earthquakeResponse.features.map { feature in
                        Earthquake(
                            magnitude: feature.properties.mag,
                            place: feature.properties.place,
                            time: Date(timeIntervalSince1970: TimeInterval(feature.properties.time / 1000)),
                            coordinates: feature.geometry.coordinates
                        )
                    }
                    
                    self?.addAnnotations()
                }
            } catch {
                print("Failed to decode earthquake data:", error)
            }
        }
        
        task.resume()
    }
    
    private func addAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
//        Now `coordinate` is of type CLLocationCoordinate2D and can be used with MKAnnotation, MKMapView this is where the coordinate data type is changed to CLLocationCoordinate2D
//        to enable annotation
        for earthquake in earthquakes {
            let annotation = MKPointAnnotation()
            
            guard earthquake.coordinates.count >= 2 else {
                continue
            }
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: earthquake.coordinates[1], longitude: earthquake.coordinates[0])
            annotation.title = "Magnitude: \(earthquake.magnitude)"
            annotation.subtitle = earthquake.place
            mapView.addAnnotation(annotation)
        }
        
//        Map now retrns the annotations with the magnitude
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
}
