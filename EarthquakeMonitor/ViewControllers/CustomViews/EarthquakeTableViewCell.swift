//
//  EarthquakeTableViewCell.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/18/24.
//

import Foundation
import UIKit

class EarthquakeTableViewCell: UITableViewCell {
    static let identifier = "EarthquakeTableViewCell"
    
    private let magnitudeLabel = UILabel()
    private let placeLabel = UILabel()
    private let timeLabel = UILabel()
    private let depthLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        magnitudeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        placeLabel.font = UIFont.systemFont(ofSize: 16)
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        depthLabel.font = UIFont.systemFont(ofSize: 14)
        
        let stackView = UIStackView(arrangedSubviews: [magnitudeLabel, placeLabel, timeLabel, depthLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with earthquake: Earthquake) {
        magnitudeLabel.text = "Magnitude: \(earthquake.magnitude)"
        placeLabel.text = "Location: \(earthquake.place)"
        timeLabel.text = "Time: \(DateFormatter.localizedString(from: earthquake.time, dateStyle: .short, timeStyle: .short))"
        depthLabel.text = "Depth: \(earthquake.coordinates.count > 2 ? "\(earthquake.coordinates[2]) km" : "Unknown")"
    }
}
