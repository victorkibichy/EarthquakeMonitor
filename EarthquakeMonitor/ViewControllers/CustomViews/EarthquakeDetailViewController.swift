//
//  EarthquakeDetailViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/18/24.
//

import UIKit
import MapKit

class EarthquakeDetailViewController: UIViewController {
    private let earthquake: Earthquake
    
    private let magnitudeLabel = UILabel()
    private let placeLabel = UILabel()
    private let timeLabel = UILabel()
    private let depthLabel = UILabel()
    private let mapView = MKMapView()
    
    init(earthquake: Earthquake) {
        self.earthquake = earthquake
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Earthquake Details"
        
        magnitudeLabel.font = UIFont.boldSystemFont(ofSize: 24)
        placeLabel.font = UIFont.systemFont(ofSize: 20)
        timeLabel.font = UIFont.systemFont(ofSize: 18)
        depthLabel.font = UIFont.systemFont(ofSize: 18)
        
        let stackView = UIStackView(arrangedSubviews: [magnitudeLabel, placeLabel, timeLabel, depthLabel, mapView])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        mapView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    private func configureData() {
        magnitudeLabel.text = "Magnitude: \(earthquake.magnitude)"
        placeLabel.text = "Location: \(earthquake.place)"
        timeLabel.text = "Time: \(DateFormatter.localizedString(from: earthquake.time, dateStyle: .medium, timeStyle: .short))"
        depthLabel.text = "Depth: \(earthquake.coordinates.count > 2 ? "\(earthquake.coordinates[2]) km" : "Unknown")"
        
        if earthquake.coordinates.count >= 2 {
            let coordinate = CLLocationCoordinate2D(latitude: earthquake.coordinates[1], longitude: earthquake.coordinates[0])
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
}
