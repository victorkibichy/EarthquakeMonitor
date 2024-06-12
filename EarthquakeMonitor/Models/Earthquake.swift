//
//  Earthquake.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/12/24.
//

import Foundation

import Foundation

// DECLARING THE DATA TO CONFORM TO THE CODABLE PROTOCOL


struct Earthquake: Codable {
    let magnitude: Double
    let place: String
    let time: Date
    let coordinates: [Double] // this is the coordinates tthat pend modifications [longitude, latitude, depth]
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
