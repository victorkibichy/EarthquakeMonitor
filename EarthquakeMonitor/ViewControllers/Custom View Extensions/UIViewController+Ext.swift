//
//  UIViewController+Ext.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/24/24.
//

import Foundation
import UIKit

extension UIViewController {
    
   func presentGFAlertOnMainThread(title: String, message: String, buttonTitle:String) {
       DispatchQueue.main.async {
           let alertVC = EMAlertVC(title: title, message: message, buttonTitle: buttonTitle)
           alertVC.modalPresentationStyle = .overFullScreen
           alertVC.modalTransitionStyle = .crossDissolve
           self.present(alertVC, animated: true)
           
       }
    }
    
}
