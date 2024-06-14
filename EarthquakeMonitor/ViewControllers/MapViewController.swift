//
//  MapViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//

import UIKit
import MapKit

import UIKit
import MapKit

class MapViewController: UIViewController {
    var mapView: MKMapView!
    private var earthquakes: [Earthquake] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Earthquakes History"
        
        setupMapView()
        fetchEarthquakeData() // this is toFetch and display earthquake data on map
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
        
        // Optionally, you can zoom the map to fit all annotations
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
}
