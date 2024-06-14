//
//  LegendView.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/14/24.
//

import Foundation
// LegendView.swift
import UIKit

class LegendView: UIView {
    
    // Initialize legend items (colors and descriptions)
    private let items: [(color: UIColor, description: String)] = [
        (.blue, "Magnitude < 2.0: Light Earthquake"),
        (.green, "Magnitude 2.0 - 3.9: Minor Earthquake"),
        (.orange, "Magnitude 4.0 - 5.9: Moderate Earthquake"),
        (.red, "Magnitude 6.0 - 6.9: Strong Earthquake"),
        (.purple, "Magnitude ≥ 7.0: Major Earthquake")
    ]
    
    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // Setup the legend view
    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        // Add legend items to the stack view
        for item in items {
            let legendItem = createLegendItem(color: item.color, description: item.description)
            stackView.addArrangedSubview(legendItem)
        }
    }
    
    // Create a view for each legend item
    private func createLegendItem(color: UIColor, description: String) -> UIView {
        let legendItemView = UIView()
        legendItemView.translatesAutoresizingMaskIntoConstraints = false
        
        let colorView = UIView()
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 5
        colorView.layer.masksToBounds = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
        legendItemView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 20),
            colorView.heightAnchor.constraint(equalToConstant: 20),
            colorView.leadingAnchor.constraint(equalTo: legendItemView.leadingAnchor),
            colorView.topAnchor.constraint(equalTo: legendItemView.topAnchor),
            colorView.bottomAnchor.constraint(equalTo: legendItemView.bottomAnchor)
        ])
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        legendItemView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: legendItemView.trailingAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: colorView.centerYAnchor)
        ])
        
        return legendItemView
    }
}
