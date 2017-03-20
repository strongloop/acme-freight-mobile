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
    
    @IBAction func resetButtonTapped() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to reset to default settings?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { action in
            self.resetFields()
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFields()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func loadFields() {
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
    
    private func resetFields() {
        
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
