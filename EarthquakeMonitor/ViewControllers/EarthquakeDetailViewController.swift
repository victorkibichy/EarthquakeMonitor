//
//  EarthquakeDetailViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/18/24.
//

import UIKit
import MapKit

class EarthquakeDetailViewController: UIViewController, MKMapViewDelegate {
    private let viewModel: EarthquakeDetailViewModel
    
    private let magnitudeLabel = UILabel()
    private let placeLabel = UILabel()
    private let timeLabel = UILabel()
    private let depthLabel = UILabel()
    private let mapView = MKMapView()
    
    init(viewModel: EarthquakeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        
        mapView.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Earthquake Details"
        
        magnitudeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        placeLabel.font = UIFont.systemFont(ofSize: 15)
        magnitudeLabel.textColor = UIColor.red
        placeLabel.textColor = UIColor.green
        timeLabel.textColor = UIColor.systemTeal
        timeLabel.font = UIFont.systemFont(ofSize: 15)
        depthLabel.font = UIFont.systemFont(ofSize: 15)
        
        let stackView = UIStackView(arrangedSubviews: [placeLabel, magnitudeLabel, timeLabel, depthLabel, mapView])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        mapView.heightAnchor.constraint(equalToConstant: 500).isActive = true
    }
    
    private func bindViewModel() {
       
        magnitudeLabel.text = viewModel.magnitudeText
        placeLabel.text = viewModel.placeText
        timeLabel.text = viewModel.timeText
        depthLabel.text = viewModel.depthText
        
        if let coordinate = viewModel.coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = viewModel.annotationTitle
            mapView.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // This method is called when an annotation is tapped
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Ensure the annotation is an MKPointAnnotation
        guard let annotation = view.annotation as? MKPointAnnotation else { return }
        
        // Create an instance of MapViewController
        let mapVC = MapViewController()
        
        // Pass the current earthquake data from the ViewModel
        mapVC.earthquake = viewModel.earthquakeData
        
        // Push the MapViewController onto the navigation stack
        navigationController?.pushViewController(mapVC, animated: true)
    }
}
