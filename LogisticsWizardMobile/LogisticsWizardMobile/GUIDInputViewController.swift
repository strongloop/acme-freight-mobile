//
//  GUIDInputViewController.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 4/4/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit

private extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class GUIDInputViewController: UIViewController {
    
    @IBOutlet weak var instructionLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?

    let pinInput: PinInput = {
        let view = PinInput()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pin Input"
        view.backgroundColor = "466BB0".hexColor
        
        pinInput.addTarget(self, action: #selector(pinFilled), for: .primaryActionTriggered)
        view.addSubview(pinInput)
        
        NSLayoutConstraint.activate([
            pinInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinInput.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pinInput.becomeFirstResponder()
    }
    
    @objc private func pinFilled() {
        print("Pin: \(pinInput.value)")
        var pinString = String()
        for digit in pinInput.value {
            pinString.append(String(digit))
        }
        let pin = Int(pinString)
        guard let instructionLabel = instructionLabel else { return }
        guard let activityIndicator = activityIndicator else { return }
        instructionLabel.text = "Validating identifier..."
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            let defaults = UserDefaults.standard
            defaults.set(pin, forKey: TripParameterConstantKeys.guidPersistence)
            defaults.set(false, forKey: EnvVarConstantKeys.requiresGUID)
            if defaults.synchronize() {
                instructionLabel.text = "Logged in"
                activityIndicator.stopAnimating()
                self.pinInput.resignFirstResponder()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: { 
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                instructionLabel.text = "Try again"
                activityIndicator.stopAnimating()
            }
        }
    }
}
