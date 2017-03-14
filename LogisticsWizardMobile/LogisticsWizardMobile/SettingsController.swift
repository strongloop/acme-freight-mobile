//
//  SettingsController.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 3/14/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit

class SettingsController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var hostURLField: UITextField?
    @IBOutlet weak var openWhiskTokenField: UITextField?
    
    @IBAction func saveButtonTapped() {
        if saveFields(), let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            print("Error saving fields")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let hostURLField = hostURLField {
            hostURLField.text = UserDefaults.standard.string(forKey: WebAPIConstantKeys.hostURLKey)
            hostURLField.delegate = self
            hostURLField.keyboardType = .URL
        }
        if let openWhiskTokenField = openWhiskTokenField {
            openWhiskTokenField.text = UserDefaults.standard.string(forKey: WebAPIConstantKeys.openWhiskTokenKey)
            openWhiskTokenField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func saveFields() -> Bool {
        if let hostURLField = hostURLField, let openWhiskTokenField = openWhiskTokenField {
            UserDefaults.standard.set(hostURLField.text, forKey: WebAPIConstantKeys.hostURLKey)
            UserDefaults.standard.set(openWhiskTokenField.text, forKey: WebAPIConstantKeys.openWhiskTokenKey)
            return UserDefaults.standard.synchronize()
        } else {
            return false
        }
    }
}
