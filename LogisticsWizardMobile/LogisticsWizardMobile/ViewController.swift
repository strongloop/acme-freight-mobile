//
//  ViewController.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 3/8/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit

private extension UIAlertController {
    func addCancelButton() {
        addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func addOKButton(_ withAction : ((UIAlertAction) -> Swift.Void)?) {
        addAction(UIAlertAction(title: "OK", style: .default, handler: withAction))
    }
}

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

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = "466BB0".hexColor
        navigationController?.navigationBar.isTranslucent = false
        let logo = UIImage(named: "API Connect_logo_white")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        imageView.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        navigationItem.titleView = imageView
    }
    
    @IBAction func shipmentButtonTapped() {
        let alert = UIAlertController(title: "Shipment Failed", message: "Reference: \(randomString(8))", preferredStyle: .alert)
        alert.addCancelButton()
        alert.addOKButton(nil)
        present(alert, animated: true, completion: nil)
    }

    private func randomString(_ length: Int) -> String {
        let letters : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = letters.characters.count
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(UInt32(len))
            randomString += "\(letters[letters.index(letters.startIndex, offsetBy: Int(rand))])"
        }
        return randomString
    }
}

