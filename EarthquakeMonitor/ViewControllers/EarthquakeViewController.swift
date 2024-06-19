//
//  EarthquakeViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//

import Foundation
import UIKit
import Combine

class EarthquakeViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = EarthquakeViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private let mapView = MapViewController() // Instantiate MapViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        viewModel.fetchEarthquakes()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Earthquakes Data"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self // Set delegate for handling row selection
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$earthquakes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.presentAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func presentAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension EarthquakeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.earthquakes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let earthquake = viewModel.earthquakes[indexPath.row]
        
        // Customize cell text with colored components
        let magnitudeText = "\(earthquake.magnitude)"
        let placeText = " ➡️ \(earthquake.place)"
        
        let attributedText = NSMutableAttributedString(string: magnitudeText + placeText)
        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: magnitudeText.count))
        attributedText.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange(location: magnitudeText.count, length: placeText.count))
        
        cell.textLabel?.attributedText = attributedText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEarthquake = viewModel.earthquakes[indexPath.row]
        mapView.didSelectEarthquake(selectedEarthquake)
        navigationController?.pushViewController(mapView, animated: true) // Navigate to map view
    }
}
