//
//  EarthquakeViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//

import UIKit
import Combine
import Network

class EarthquakeViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = EarthquakeViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private let mapView = MapViewController() // Reference to the MapViewController
    
    // Define the refresh control
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        setupNetworkMonitoring()
        viewModel.fetchEarthquakes()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Earthquakes Data"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add refresh control to the table view
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.tintColor = .gray
        
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
        let alert = UIAlertController(title: "Sort Options", message: "Sort earthquakes by:", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Magnitude", style: .default, handler: { [weak self] _ in
            self?.viewModel.sortEarthquakes(by: .magnitude)
        }))
        
        alert.addAction(UIAlertAction(title: "Date (Default)", style: .default, handler: { [weak self] _ in
            self?.viewModel.sortEarthquakes(by: .date)
        }))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.systemTeal, forKey: "titleTextColor")
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    @objc private func searchButtonTapped() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Earthquakes"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc private func refreshData(_ sender: Any) {
        viewModel.fetchEarthquakes()
        
        // End refreshing after data is fetched
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
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
    
    private func setupNetworkMonitoring() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue.global(qos: .background)
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Network connection is back, optionally refresh data
                DispatchQueue.main.async {
                    self.refreshData(self.refreshControl)
                }
            } else {
                // No network connection, handle accordingly
            }
        }
        
        monitor.start(queue: queue)
    }
}

extension EarthquakeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.earthquakes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let earthquake = viewModel.earthquakes[indexPath.row]
        
        // Format magnitude to one decimal place and make it bold
        let magnitudeText = String(format: "%.1f", earthquake.magnitude)
        let placeText = " ➡️ \(earthquake.place)"
        
        let attributedText = NSMutableAttributedString(string: magnitudeText + placeText)
        
        // Apply red color and bold font to the magnitude part
        let boldFont = UIFont.boldSystemFont(ofSize: cell.textLabel?.font.pointSize ?? UIFont.systemFontSize)
        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: magnitudeText.count))
        attributedText.addAttribute(.font, value: boldFont, range: NSRange(location: 0, length: magnitudeText.count))
        
        // Determine place text color based on user interface style (light or dark mode)
        let placeColor: UIColor
        if traitCollection.userInterfaceStyle == .dark {
            placeColor = .white
        } else {
            placeColor = .black
        }
        
        // Apply place text color
        attributedText.addAttribute(.foregroundColor, value: placeColor, range: NSRange(location: magnitudeText.count, length: placeText.count))
        
        // Apply bold font to the place part
        attributedText.addAttribute(.font, value: boldFont, range: NSRange(location: magnitudeText.count, length: placeText.count))
        
        cell.textLabel?.attributedText = attributedText
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEarthquake = viewModel.earthquakes[indexPath.row]
        mapView.didSelectEarthquake(selectedEarthquake)
        navigationController?.pushViewController(mapView, animated: true)
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
