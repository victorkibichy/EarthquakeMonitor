//
//  Earthquake.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//

// Earthquake.swift
// EarthquakeMonitor

import Foundation

struct Earthquake: Identifiable {
    let id = UUID()
    let magnitude: Double
    let place: String
    let time: Date
    let coordinates: [Double]
}

struct EarthquakeResponse: Decodable {
    let features: [Feature]
}

struct Feature: Decodable {
    let properties: Properties
    let geometry: Geometry
}

struct Properties: Decodable {
    let mag: Double
    let place: String
    let time: Int64
}

struct Geometry: Decodable {
    let coordinates: [Double]
}
