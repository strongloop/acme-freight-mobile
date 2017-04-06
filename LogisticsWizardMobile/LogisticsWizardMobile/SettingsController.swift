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
    @IBOutlet weak var defaultLatitudeField: UITextField?
    @IBOutlet weak var defaultLongitudeField: UITextField?
    @IBOutlet weak var useDefaultLocationSwitch: UISwitch?
    
    @IBAction func saveButtonTapped() {
        saveFields()
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            print("Error saving fields")
        }
    }
    
    @IBAction func switchValueChanged() {
        if let useDefaultLocationSwitch = useDefaultLocationSwitch, let defaultLongitudeField = defaultLongitudeField, let defaultLatitudeField = defaultLatitudeField {
            defaultLatitudeField.isEnabled = useDefaultLocationSwitch.isOn
            defaultLongitudeField.isEnabled = useDefaultLocationSwitch.isOn
        }
        let _ = saveFields()
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
            hostURLField.text = UserDefaults.standard.string(forKey: WebAPIConstantKeys.hostURL)
            hostURLField.delegate = self
            hostURLField.keyboardType = .URL
        }
        if let openWhiskTokenField = openWhiskTokenField {
            openWhiskTokenField.text = UserDefaults.standard.string(forKey: WebAPIConstantKeys.openWhiskToken)
            openWhiskTokenField.delegate = self
        }
        if let defaultLatitudeField = defaultLatitudeField {
            if String(UserDefaults.standard.double(forKey: WebAPIConstantKeys.defaultLatitude)) == "0.0" {
                defaultLatitudeField.text = EnvVarConstantKeys.defaultLatitude
            } else {
                defaultLatitudeField.text = String(UserDefaults.standard.double(forKey: WebAPIConstantKeys.defaultLatitude))
            }
            defaultLatitudeField.delegate = self
        }
        if let defaultLongitudeField = defaultLongitudeField {
            if String(UserDefaults.standard.double(forKey: WebAPIConstantKeys.defaultLongitude)) == "0.0" {
                defaultLongitudeField.text = EnvVarConstantKeys.defaultLongitude
            } else {
                defaultLongitudeField.text = String(UserDefaults.standard.double(forKey: WebAPIConstantKeys.defaultLongitude))
            }
            defaultLongitudeField.delegate = self
        }
        if let useDefaultLocationSwitch = useDefaultLocationSwitch {
            useDefaultLocationSwitch.isOn = UserDefaults.standard.bool(forKey: WebAPIConstantKeys.shouldUseDefaultLocation)
            switchValueChanged()
        }
    }
    
    private func resetFields() {
        if let hostURLField = hostURLField {
            hostURLField.text = EnvVarConstantKeys.defaultHostURL
        }
        if let openWhiskTokenField = openWhiskTokenField {
            openWhiskTokenField.text = EnvVarConstantKeys.defaultOpenWhiskToken
        }
        if let defaultLatitudeField = defaultLatitudeField {
            defaultLatitudeField.text = EnvVarConstantKeys.defaultLatitude
        }
        if let defaultLongitudeField = defaultLongitudeField {
            defaultLongitudeField.text = EnvVarConstantKeys.defaultLongitude
        }
        if let useDefaultLocationSwitch = useDefaultLocationSwitch {
            useDefaultLocationSwitch.isOn = false
        }
        switchValueChanged()
    }
    
    private func saveFields() {
        if let hostURLField = hostURLField {
            UserDefaults.standard.set(hostURLField.text, forKey: WebAPIConstantKeys.hostURL)
        }
        if let openWhiskTokenField = openWhiskTokenField {
            UserDefaults.standard.set(openWhiskTokenField.text, forKey: WebAPIConstantKeys.openWhiskToken)
        }
        if let defaultLatitudeField = defaultLatitudeField, let latitudeString = defaultLatitudeField.text {
            guard let latitude = Double(latitudeString) else { return }
            UserDefaults.standard.set(latitude, forKey: WebAPIConstantKeys.defaultLatitude)
        }
        if let defaultLongitudeField = defaultLongitudeField, let longitudeString = defaultLongitudeField.text {
            guard let longitude = Double(longitudeString) else { return }
            UserDefaults.standard.set(longitude, forKey: WebAPIConstantKeys.defaultLongitude)
        }
        if let useDefaultLocationSwitch = useDefaultLocationSwitch {
            UserDefaults.standard.set(useDefaultLocationSwitch.isOn, forKey: WebAPIConstantKeys.shouldUseDefaultLocation)
        }
        UserDefaults.standard.synchronize()
    }
}
