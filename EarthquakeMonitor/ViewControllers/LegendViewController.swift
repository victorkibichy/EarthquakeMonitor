//
//  LegendView.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/14/24.
//

import UIKit

class LegendViewController: UIViewController {
    
    // Initialize legend items (colors and descriptions)
    private let items: [(color: UIColor, description: String)] = [
        (.blue, "Magnitude < 2.0: Light Earthquake"),
        (.green, "Magnitude 2.0 - 3.9: Minor Earthquake"),
        (.orange, "Magnitude 4.0 - 5.9: Moderate Earthquake"),
        (.red, "Magnitude 6.0 - 6.9: Strong Earthquake"),
        (.purple, "Magnitude ≥ 7.0: Major Earthquake")
    ]
    
    // Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // Setup the legend view
    private func setupView() {
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill  // Adjusted alignment to fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        // Add constraints to stackView
        let topConstraint = stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
        let leadingConstraint = stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        let trailingConstraint = stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        let bottomConstraint = stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        bottomConstraint.priority = .defaultHigh  // Lower priority to allow height to be determined by content
        
        NSLayoutConstraint.activate([
            topConstraint,
            leadingConstraint,
            trailingConstraint,
            bottomConstraint
        ])
        
        // Add legend items to the stack view
        for (index, item) in items.enumerated() {
            let legendItem = createLegendItem(color: item.color, description: item.description)
            stackView.addArrangedSubview(legendItem)
            
            // Add equal height constraint to ensure last item stretches
            if index == items.count - 1 {
                legendItem.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            }
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
        descriptionLabel.numberOfLines = 0  // Allow multiline descriptions
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        legendItemView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: legendItemView.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: legendItemView.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: legendItemView.bottomAnchor)
        ])
        
        return legendItemView
    }
}
