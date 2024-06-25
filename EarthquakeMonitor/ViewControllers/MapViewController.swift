//
//  MapViewController.swift
//  EarthquakeMonitor
//
//  Created by Bouncy Baby on 6/12/24.
//

import UIKit
import MapKit
import CoreLocation // Import CoreLocation to handle user location

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var mapView: MKMapView!
    var earthquake: Earthquake?
    private var earthquakes: [Earthquake] = []
    private var mapTypeSegmentedControl: UISegmentedControl!
    private var compassButton: MKCompassButton!
    private let locationManager = CLLocationManager() // Location manager to handle user location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Earthquakes History"
        
        setupMapView()
        setupMapControls()
        setupLocationManager() // Setup location manager
        fetchEarthquakeData()
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
        
        mapView.showsUserLocation = true // Show user location on the map
        mapView.showsTraffic = true
        mapView.showsScale = true
        mapView.showsCompass = true
        
        mapView.delegate = self
    }
    
    private func setupMapControls() {
        // Map type segmented control
        mapTypeSegmentedControl = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
        mapTypeSegmentedControl.selectedSegmentIndex = 0
        mapTypeSegmentedControl.addTarget(self, action: #selector(mapTypeChanged(_:)), for: .valueChanged)
        navigationItem.titleView = mapTypeSegmentedControl
        
        // Compass button
        compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        mapView.addSubview(compassButton)
        
        // Legend button
        let legendButton = UIButton(type: .infoLight)
        legendButton.addTarget(self, action: #selector(showLegend), for: .touchUpInside)
        let legendBarItem = UIBarButtonItem(customView: legendButton)
        navigationItem.rightBarButtonItem = legendBarItem
        
        
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // Request location access
    }
    
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
    
    @objc private func showLegend() {
        let legendVC = LegendViewController()
        let navController = UINavigationController(rootViewController: legendVC)
        navController.modalPresentationStyle = .popover
        if let popoverPresentationController = navController.popoverPresentationController {
            popoverPresentationController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(navController, animated: true, completion: nil)
    }
    
    func didSelectEarthquake(_ earthquake: Earthquake) {
        guard mapView != nil else {
            print("Error: mapView is nil.")
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: earthquake.coordinates[1], longitude: earthquake.coordinates[0])
        
        // Calculate the span (region size)
        let span = MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
        
        // Create a region centered on the selected earthquake
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                mapView.setRegion(region, animated: true)
        // Set the region on the map view
        mapView.setRegion(region, animated: true)
        
        // Optionally, add an enlarged annotation
        addEnlargedAnnotation(for: earthquake)
    }

    private func addEnlargedAnnotation(for earthquake: Earthquake) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: earthquake.coordinates[1], longitude: earthquake.coordinates[0])
        annotation.title = "Magnitude: \(earthquake.magnitude)"
        annotation.subtitle = earthquake.place
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        // Select the annotation to display the callout immediately
        mapView.selectAnnotation(annotation, animated: true)
    }

    
    private func fetchEarthquakeData() {
        guard let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson") else {
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
                    
                    self?.addAnnotations() // Call addAnnotations after data is fetched
                }
            } catch {
                print("Failed to decode earthquake data:", error)
            }
        }
        
        task.resume()
    }
    
    private func addAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
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
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        
        let identifier = EarthquakeAnnotationView.identifier
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? EarthquakeAnnotationView
        
        if annotationView == nil {
            annotationView = EarthquakeAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    // CLLocationManagerDelegate method to handle authorization changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Handle denied access to location
            showLocationAccessDeniedAlert()
        default:
            break
        }
    }
    
    private func showLocationAccessDeniedAlert() {
        let alert = UIAlertController(title: "Location Access Denied", message: "To use this feature, please enable location access in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
