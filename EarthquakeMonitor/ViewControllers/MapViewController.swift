//
//  MapViewController.swift
//  EarthquakeMonitor
//
//  Created by Bouncy Baby on 6/12/24.
//

import UIKit
import MapKit
import CoreLocation
import Combine

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    var mapView: MKMapView!
    var earthquake: Earthquake?
    private var mapTypeSegmentedControl: UISegmentedControl!
    private var compassButton: MKCompassButton!
    private var searchBar: UISearchBar!
    private let locationManager = CLLocationManager()
    
    private var viewModel = MapViewModel()
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Earthquakes History"
        
        setupMapView()
        setupMapControls()
        setupSearchBar()
        setupLocationManager()
        fetchDataAndObserve()
        createDismissKeyboardTapGesture()
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
        
        mapView.delegate = self
    }
    
    private func setupMapControls() {
        mapTypeSegmentedControl = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
        mapTypeSegmentedControl.selectedSegmentIndex = 0
        mapTypeSegmentedControl.addTarget(self, action: #selector(mapTypeChanged(_:)), for: .valueChanged)
        navigationItem.titleView = mapTypeSegmentedControl
        
        compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        mapView.addSubview(compassButton)
        
        let legendButton = UIButton(type: .infoLight)
        legendButton.addTarget(self, action: #selector(showLegend), for: .touchUpInside)
        let legendBarItem = UIBarButtonItem(customView: legendButton)
        navigationItem.rightBarButtonItem = legendBarItem
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search for places"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.isTranslucent = true
        searchBar.barTintColor = UIColor.clear
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            textField.textColor = .black
        }
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
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

    private func fetchDataAndObserve() {
        // Fetch earthquake data using the ViewModel
        viewModel.fetchEarthquakeData()
        
        // Observe changes in the ViewModel's earthquakes property
        viewModel.$earthquakes
            .sink { [weak self] earthquakes in
                self?.updateAnnotations(with: earthquakes)
            }
            .store(in: &cancellables)
        
        // Observe changes in the ViewModel's errorMessage property
        viewModel.$errorMessage
            .sink { errorMessage in
                if let message = errorMessage {
                    print("Error: \(message)")
                }
            }
            .store(in: &cancellables)
    }

    private func updateAnnotations(with earthquakes: [Earthquake]) {
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
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
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        let localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchText
        
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (response, error) in
            guard let response = response, error == nil else {
                print("Error searching for places:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let firstMapItem = response.mapItems.first {
                let placemark = firstMapItem.placemark
                let coordinate = placemark.coordinate
                
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                self?.mapView.setRegion(region, animated: true)
            }
        }
        
        searchBar.resignFirstResponder()
    }
    
    func createDismissKeyboardTapGesture() {
           let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
           view.addGestureRecognizer(tap)
    }
}
