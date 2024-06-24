//
//  EMAlertVCViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/24/24.
//

import UIKit

class EMAlertVCViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let containerView = UIView()
        let titleLabel = EMTitleLabel(textAlignment: .center, fontsize: 20)
        let messageLabel = EMBodyLabel(textAlignment: .center)
        let actionButton = EMButton(backgroundColor: .systemTeal, title: "OK")
    }
    

}
