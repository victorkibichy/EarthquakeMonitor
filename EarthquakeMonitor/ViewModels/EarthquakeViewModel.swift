//  EarthquakeViewModel.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//

import Foundation
import Combine

class EarthquakeViewModel {
    @Published var earthquakes: [Earthquake] = []
    @Published var errorMessage: String? // To communicate errors to the User
    private var cancellables: Set<AnyCancellable> = []
    private var allEarthquakes: [Earthquake] = [] // an array to Store all earthquakes to support search functionality

    // Fetch earthquakes from the USGS API
    func fetchEarthquakes() {
        let urlString = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2022-01-01&endtime=2022-01-02"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: EarthquakeResponse.self, decoder: JSONDecoder())
            .map { response in
                response.features.map { feature in
                    Earthquake(
                        magnitude: feature.properties.mag,
                        place: feature.properties.place,
                        time: Date(timeIntervalSince1970: TimeInterval(feature.properties.time / 1000)),
                        coordinates: feature.geometry.coordinates
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Handle specific error types and set appropriate error messages
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] earthquakes in
                self?.allEarthquakes = earthquakes
                self?.earthquakes = earthquakes
            })
            .store(in: &cancellables)
    }
    
    // Handle different types of errors
    private func handleError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = ErrorType.notConnectedToInternet.rawValue
            case .timedOut:
                errorMessage = ErrorType.timedOut.rawValue
            case .cannotFindHost:
                errorMessage = ErrorType.cannotFindHost.rawValue
            case .badServerResponse:
                errorMessage = ErrorType.badServerResponse.rawValue
            default:
                errorMessage = "An unexpected error occurred: \(urlError.localizedDescription)"
            }
        } else if let decodingError = error as? DecodingError {
            errorMessage = "Failed to parse earthquake data. Please try again."
        } else {
            errorMessage = "An unknown error occurred: \(error.localizedDescription)"
        }
        print(errorMessage ?? "Unknown error")
    }
    
    // Sorting earthquakes based on the specified criterion
    func sortEarthquakes(by criterion: SortCriterion) {
        switch criterion {
//            for sorting by magnitude of appearance
        case .magnitude:
            earthquakes.sort { $0.magnitude > $1.magnitude }
            
//            for sorting by date of appearance

        case .date:
            earthquakes.sort { $0.time > $1.time }
        }
    }
    
    // Search for earthquakes based on the place name
    func searchEarthquakes(by query: String) {
        earthquakes = allEarthquakes.filter { $0.place.lowercased().contains(query.lowercased()) }
    }
    
    // Reset the search to show all earthquakes
    func resetSearch() {
        earthquakes = allEarthquakes
    }
}

enum SortCriterion {
    case magnitude
    case date
}

