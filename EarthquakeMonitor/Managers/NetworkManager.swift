//
//  NetworkManager.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/28/24.
//

import Foundation
import Combine

class NetworkManager {
    
    func fetchEarthquakes() -> AnyPublisher<EarthquakeResponse, Error> {
        let urlString = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: EarthquakeResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
