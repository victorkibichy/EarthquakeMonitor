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
    private var cancellables: Set<AnyCancellable> = []
    
    
    
//    FERTCHING THE EARTHQUAKE DATA FOR THE LOCATIONS
   
    func fetchEarthquakes() {
        let urlString = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2022-01-01&endtime=2022-01-02"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed to fetch earthquakes: \(error)")
                }
            }, receiveValue: { [weak self] earthquakes in
                self?.earthquakes = earthquakes
            })
            .store(in: &cancellables)
    }
}
