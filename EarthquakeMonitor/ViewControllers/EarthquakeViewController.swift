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
    private let mapView = MapViewController() // Instantiate MapViewController to enable navigation reference
    
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
        
        // Add buttons to navigation bar
        addNavigationBarButtons()
    }
    
    private func addNavigationBarButtons() {
        // Sort button on the top right
        let sortButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortButtonTapped))
        sortButton.tintColor = UIColor.systemTeal
        navigationItem.rightBarButtonItem = sortButton
        
        // Search button on the top left
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        searchButton.tintColor = UIColor.systemTeal
        navigationItem.leftBarButtonItem = searchButton
    }

    
    @objc private func sortButtonTapped() {
        // this is to Handle sort button tap
        let alert = UIAlertController(title: "Sort Options", message: "Sort earthquakes by:", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Magnitude", style: .default, handler: { [weak self] _ in
            self?.viewModel.sortEarthquakes(by: .magnitude)
        }))
        alert.addAction(UIAlertAction(title: "Date (Default)", style: .default, handler: { [weak self] _ in
            self?.viewModel.sortEarthquakes(by: .date)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func searchButtonTapped() {
        // Handle search button tap
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Earthquakes"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
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
        
        // Create an attributed string
        let attributedText = NSMutableAttributedString(string: magnitudeText + placeText)
        
        // Set the color and font for the magnitude text
        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: magnitudeText.count))
        
        // Determine the current interface style (light or dark mode)
        let placeColor: UIColor
        if traitCollection.userInterfaceStyle == .dark {
            placeColor = .white
        } else {
            placeColor = .black
        }
        
        // Set the color and font for the place text
        attributedText.addAttribute(.foregroundColor, value: placeColor, range: NSRange(location: magnitudeText.count, length: placeText.count))
        
        // Make the place text bold
        let boldFont = UIFont.boldSystemFont(ofSize: cell.textLabel?.font.pointSize ?? UIFont.systemFontSize)
        attributedText.addAttribute(.font, value: boldFont, range: NSRange(location: magnitudeText.count, length: placeText.count))
        
        // Assign the attributed text to the cell's textLabel
        cell.textLabel?.attributedText = attributedText
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEarthquake = viewModel.earthquakes[indexPath.row]
        mapView.didSelectEarthquake(selectedEarthquake)
        navigationController?.pushViewController(mapView, animated: true) //function to Navigate to map view to the indexed annotation
    }
}

extension EarthquakeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            viewModel.resetSearch()
            return
        }
        viewModel.searchEarthquakes(by: query)
    }
}
