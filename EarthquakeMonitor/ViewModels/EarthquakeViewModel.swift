//
//  EarthquakeViewModel.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//

import Foundation
import Combine

class EarthquakeViewModel {
    @Published var earthquakes: [Earthquake] = []
    @Published var errorMessage: String? // To communicate errors to the UI
    private var cancellables: Set<AnyCancellable> = []
    
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
                self?.earthquakes = earthquakes
            })
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        // CATEGORIES OF ERRORS
        
        
        
        
        if let urlError = error as? URLError {
            
            switch urlError.code {
                
            case .notConnectedToInternet:
                errorMessage = "No internet connection. Please check your network settings."
                
            case .timedOut:
                errorMessage = "The request timed out. Please try again."
                
            case .cannotFindHost:
                errorMessage = "Cannot find host. Please check the server address."
                
                
            case .badServerResponse:
                errorMessage = "Server error. Please try again later."
                
            default:
                errorMessage = "An unexpected error occurred: \(urlError.localizedDescription)"
            }
            
        }
        
        else if let decodingError = error as? DecodingError {
            errorMessage = "Failed to parse earthquake data. Please try again."
        }
        
        else {
            errorMessage = "An unknown error occurred: \(error.localizedDescription)"
        }
        print(errorMessage ?? "Unknown error")
    }
}
