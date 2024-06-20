//
//  EarthquakeViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//


// EarthquakeViewController.swift
// EarthquakeMonitor

import UIKit
import Combine

class EarthquakeViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = EarthquakeViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private let mapView = MapViewController() // Reference to the MapViewController
    
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
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
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
        
        let magnitudeText = "\(earthquake.magnitude)"
        let placeText = " ➡️ \(earthquake.place)"
        
        let attributedText = NSMutableAttributedString(string: magnitudeText + placeText)
        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: magnitudeText.count))
        
        let placeColor: UIColor
        if traitCollection.userInterfaceStyle == .dark {
            placeColor = .white
        } else {
            placeColor = .black
        }
        
        attributedText.addAttribute(.foregroundColor, value: placeColor, range: NSRange(location: magnitudeText.count, length: placeText.count))
        
        let boldFont = UIFont.boldSystemFont(ofSize: cell.textLabel?.font.pointSize ?? UIFont.systemFontSize)
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
