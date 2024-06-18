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
    
    // Title label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Map Legend"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    // Dismiss button
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(dismissLegend), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    // Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // Setup the legend view
    private func setupView() {
        view.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        // Shadow and border
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        
        // Stack view for title, dismiss button, and legend items
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center  // Center alignment
        stackView.spacing = 8  // Reduced spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        // Add title label
        stackView.addArrangedSubview(titleLabel)
        
        // Add dismiss button
        let dismissStackView = UIStackView(arrangedSubviews: [UIView(), dismissButton])
        dismissStackView.spacing = 12
        stackView.addArrangedSubview(dismissStackView)
        
        // Add legend items to the stack view
        for item in items {
            let legendItem = createLegendItem(color: item.color, description: item.description)
            stackView.addArrangedSubview(legendItem)
        }
        
        // Calculate half of the screen height
        let halfScreenHeight = UIScreen.main.bounds.height / 2
        
        // Add constraints to stack view
        let centerYConstraint = stackView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: halfScreenHeight)
        let leadingConstraint = stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        let trailingConstraint = stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        let maxHeightConstraint = stackView.heightAnchor.constraint(lessThanOrEqualToConstant: halfScreenHeight - 40)
        maxHeightConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            centerYConstraint,
            leadingConstraint,
            trailingConstraint,
            maxHeightConstraint
        ])
        
        // Add pan gesture recognizer to dismiss the view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
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
            colorView.widthAnchor.constraint(equalToConstant: 24),
            colorView.heightAnchor.constraint(equalToConstant: 24),
            colorView.leadingAnchor.constraint(equalTo: legendItemView.leadingAnchor, constant: 16),
            colorView.topAnchor.constraint(equalTo: legendItemView.topAnchor, constant: 8),
            colorView.bottomAnchor.constraint(equalTo: legendItemView.bottomAnchor, constant: -8)
        ])
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        legendItemView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: legendItemView.trailingAnchor, constant: -16),
            descriptionLabel.centerYAnchor.constraint(equalTo: colorView.centerYAnchor)
        ])
        
        return legendItemView
    }
    
    // Dismiss the legend view
    @objc private func dismissLegend() {
        dismiss(animated: true, completion: nil)
    }
    
    // Handle pan gesture to dismiss the view
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                view.frame.origin.y = translation.y
            }
        case .ended:
            if translation.y > view.frame.height / 2 {
                dismissLegend()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = 0
                }
            }
        default:
            break
        }
    }
}
