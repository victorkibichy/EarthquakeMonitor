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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        viewModel.fetchEarthquakes()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0, green: 0.69, blue: 0.64, alpha: 1.0)

        title = "Earthquakes Data"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
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
    }
}




extension EarthquakeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return viewModel.earthquakes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let earthquake = viewModel.earthquakes[indexPath.row]
        
        // Create an attributed string for the cell text
        let attributedText = NSMutableAttributedString(string: "\(earthquake.magnitude) - \(earthquake.place)")
        
        // Set RED color for magnitude component. this UI is subject ti change in the deployment
        let magnitudeRange = NSRange(location: 0, length: "\(earthquake.magnitude)".count)
        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: magnitudeRange)
        
        // Set BLACK color for the rest of the text AS FROM LOCATION
        let restOfStringRange = NSRange(location: "\(earthquake.magnitude)".count + 3, length: "\(earthquake.place)".count)
        attributedText.addAttribute(.foregroundColor, value: UIColor.blue, range: restOfStringRange)
        
        // Assign the attributed text to the cell's text label
        cell.textLabel?.attributedText = attributedText
        
        return cell
    }
    
}
