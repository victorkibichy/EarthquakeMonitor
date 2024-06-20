//
//  LegendViewModel.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/20/24.
//

import Foundation
import UIKit

class LegendViewModel {
    private let items: [LegendItem] = [
        LegendItem(color: .blue, description: "Magnitude < 2.0: Light Earthquake"),
        LegendItem(color: .green, description: "Magnitude 2.0 - 3.9: Minor Earthquake"),
        LegendItem(color: .orange, description: "Magnitude 4.0 - 5.9: Moderate Earthquake"),
        LegendItem(color: .red, description: "Magnitude 6.0 - 6.9: Strong Earthquake"),
        LegendItem(color: .purple, description: "Magnitude ≥ 7.0: Major Earthquake")
    ]
    
    var numberOfItems: Int {
        return items.count
    }
    
    func item(at index: Int) -> LegendItem? {
        guard index >= 0 && index < items.count else {
            return nil
        }
        return items[index]
    }
}
