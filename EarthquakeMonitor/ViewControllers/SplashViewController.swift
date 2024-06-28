//
//  SplashViewController.swift
//  EarthquakeMonitor
//
//  Created by  Bouncy Baby on 6/28/24.
//

import UIKit

class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let imageView = UIImageView(image: UIImage(named: "eathquake"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: view.bounds.midX - view.bounds.width / 4, y: view.bounds.midY - view.bounds.height / 4, width: view.bounds.width / 2, height: view.bounds.height / 2)
        view.addSubview(imageView)

        let label = UILabel()
        label.text = "Loading..."
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .systemTeal
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true

        startAnimations()
    }

    func startAnimations() {
        UIView.animate(withDuration: 2.5, animations: {
            self.view.alpha = 1.0
        }) { _ in
            // Transition to the main app after the animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.transitionToMainApp()
            }
        }
    }

    func transitionToMainApp() {
        NotificationCenter.default.post(name: NSNotification.Name("SplashScreenCompleted"), object: nil)
    }
}
