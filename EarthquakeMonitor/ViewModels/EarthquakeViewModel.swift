// EarthquakeViewModel.swift
// EarthquakeMonitor

import Foundation
import Combine

class EarthquakeViewModel {
    @Published var earthquakes: [Earthquake] = []
    @Published var errorMessage: String?
    private var cancellables: Set<AnyCancellable> = []
    private var allEarthquakes: [Earthquake] = []
    
    func fetchEarthquakes() {
        let urlString = "https://earthquakeson"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                if let jsonString = String(data: result.data, encoding: .utf8) {
                    print("Raw JSON: \(jsonString)")
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
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] earthquakes in
                self?.allEarthquakes = earthquakes
                self?.earthquakes = earthquakes
            })
            .store(in: &cancellables)
    }
    
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
            switch decodingError {
            case .typeMismatch(let type, let context):
                errorMessage = "Type mismatch for type \(type). \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                errorMessage = "Value not found for type \(type). \(context.debugDescription)"
            case .keyNotFound(let key, let context):
                errorMessage = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
            case .dataCorrupted(let context):
                errorMessage = "Data corrupted: \(context.debugDescription)"
            default:
                errorMessage = "Failed to parse earthquake data: \(decodingError.localizedDescription)"
            }
        } else {
            errorMessage = "An unknown error occurred: \(error.localizedDescription)"
        }
        print(errorMessage ?? "Unknown error")
    }

    func sortEarthquakes(by criterion: SortingCriterion) {
        switch criterion {
        case .magnitude:
            earthquakes.sort { $0.magnitude > $1.magnitude }
        case .date:
            earthquakes.sort { $0.time > $1.time }
        }
    }
    
    func searchEarthquakes(by query: String) {
        earthquakes = allEarthquakes.filter { $0.place.lowercased().contains(query.lowercased()) }
    }
    
    func resetSearch() {
        earthquakes = allEarthquakes
    }
}

enum SortingCriterion {
    case magnitude
    case date
}

