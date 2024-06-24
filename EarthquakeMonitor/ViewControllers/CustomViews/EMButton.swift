//
//  EMButton.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/24/24.
//

import UIKit

class EMButton: UIButton {
    
        override init(frame: CGRect) {
            
            super.init(frame: frame)
            configure()
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        init(backgroundColor: UIColor, title: String) {
            super.init(frame: .zero)
            self.backgroundColor = backgroundColor
            self.setTitle(title, for: .normal)
            configure()
        }
        
        private func configure() {
            layer.cornerRadius     =    10
            setTitleColor(.white, for: .normal)
            titleLabel?.font       =    UIFont.preferredFont(forTextStyle: .headline)
            translatesAutoresizingMaskIntoConstraints       = false
        }
        /*
         // Only override draw() if you perform custom drawing.
         // An empty implementation adversely affects performance during animation.
         override func draw(_ rect: CGRect) {
         // Drawing code
         }
         */
        
    }
    

