//
//  Earthquake.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//

import Foundation
import CoreLocation
import Foundation

struct Earthquake: Codable {
    let magnitude: Double
    let place: String
    let time: Date
    let coordinates: [Double] // Keep coordinates as [Double]

    

    init(magnitude: Double, place: String, time: Date, coordinates: [Double]) {
        self.magnitude = magnitude
        self.place = place
        self.time = time
        self.coordinates = coordinates
    }

    private enum CodingKeys: String, CodingKey {
        case magnitude = "mag"
        case place
        case time
        case coordinates = "geometry"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        magnitude = try container.decode(Double.self, forKey: .magnitude)
        place = try container.decode(String.self, forKey: .place)
        time = try container.decode(Date.self, forKey: .time)
        coordinates = try container.decode([Double].self, forKey: .coordinates)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(magnitude, forKey: .magnitude)
        try container.encode(place, forKey: .place)
        try container.encode(time, forKey: .time)
        try container.encode(coordinates, forKey: .coordinates)
    }
}

struct EarthquakeResponse: Codable {
    let features: [Feature]
}

struct Feature: Codable {
    let properties: Properties
    let geometry: Geometry
}

struct Properties: Codable {
    let mag: Double
    let place: String
    let time: Int64
}

struct Geometry: Codable {
    let coordinates: [Double]
}
