//
//  LegendView.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/14/24.
//

import Foundation
import UIKit

class LegendViewController: UIViewController {
    private let viewModel = LegendViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Map Legend"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        button.tintColor = .black
        button.addTarget(LegendViewController.self, action: #selector(dismissLegend), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        updateBackgroundColor()
        
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        
        let dismissStackView = UIStackView(arrangedSubviews: [UIView(), dismissButton])
        dismissStackView.spacing = 12
        stackView.addArrangedSubview(dismissStackView)
        
        for index in 0..<viewModel.numberOfItems {
            if let item = viewModel.item(at: index) {
                let legendItem = createLegendItem(color: item.color, description: item.description)
                stackView.addArrangedSubview(legendItem)
            }
        }
        
        let halfScreenHeight = UIScreen.main.bounds.height / 2
        
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
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
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
    
    private func updateBackgroundColor() {
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.95)
            titleLabel.textColor = .white
            dismissButton.tintColor = .white
        } else {
            view.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            titleLabel.textColor = .black
            dismissButton.tintColor = .black
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBackgroundColor()
    }
    
    @objc private func dismissLegend() {
        dismiss(animated: true, completion: nil)
    }
    
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
