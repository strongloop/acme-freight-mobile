//
//  ViewController.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 3/8/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit
import MapKit 

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

class ViewController: UIViewController, LogisticsLocationManagerDelegate {
    private var locationManager: LocationManager?
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var registerTripButton: UIButton?
    @IBOutlet weak var locationBanner: UILabel?
    @IBOutlet weak var locationLabel: UILabel?
    
    var titleBarImageView: UIImageView {
        let logo = UIImage(named: "API Connect_logo_white")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        imageView.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        imageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.settingsButtonTapped))
        tapRecognizer.numberOfTapsRequired = 4
        imageView.addGestureRecognizer(tapRecognizer)
        return imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = "466BB0".hexColor
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.titleView = titleBarImageView
        
        locationManager = LocationManager()
        if let locationManager = locationManager {
            locationManager.delegate = self
        }
        if let locationLabel = locationLabel {
            updateLabelUI(locationLabel)
            locationLabel.text = "Locating..."
        }
        if let locationBanner = locationBanner {
            updateLabelUI(locationBanner)
            locationBanner.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        }
    }
    
    func updateLabelUI(_ label: UILabel) {
        label.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        label.layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
        label.layer.shadowOpacity = 0.65
        label.layer.shadowRadius = 3.0
        label.layer.cornerRadius = 3.0
        label.layer.masksToBounds = false
    }
    
    func settingsButtonTapped() {
        performSegue(withIdentifier: "settingsSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let button = registerTripButton else {
            return
        }
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        button.layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
        button.layer.shadowOpacity = 0.65
        button.layer.masksToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let mapView = mapView else {
            return
        }
        mapView.showsUserLocation = true
    }
    
    @IBAction func registerTripButtonTapped() {
        guard let button = registerTripButton else {
            return
        }
        guard let locationManager = locationManager else {
            return
        }
        guard let location = locationManager.lastLoggedLocation else {
            return
        }
        // let coordinates = CLLocationCoordinate2DMake(34.46, -120.04)
        // uncomment when you want to fake location
        button.isEnabled = false
        UIView.animate(withDuration: 0.6) { 
            button.backgroundColor = "758196".hexColor
            button.setTitle("Registering trip...", for: .normal)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        locationManager.getLocationData(forCoordinates: location.coordinate) { data in
            let trip = Trip(locationData: data, coordinates: location.coordinate)
            WebAPI.register(trip, { shipmentID, errorReason in
                self.handleRegistrationResponse(data, shipmentID, errorReason)
            })
        }
    }
    
    private func handleRegistrationResponse(_ data: LocationData, _ shipmentID: Int?, _ errorReason: String?) {
        guard let button = registerTripButton else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        button.isEnabled = true
        UIView.animate(withDuration: 0.6) {
            button.backgroundColor = "466BB0".hexColor
            button.setTitle("Register trip", for: .normal)
        }
        if let shipmentID = shipmentID {
            let alert = UIAlertController(title: "Trip Registered", message: "Shipment #\(shipmentID)\nStarting location: \(data.city), \(data.state), \(data.country)", preferredStyle: .alert)
            alert.addOKButton(nil)
            self.present(alert, animated: true, completion: nil)
        } else if let errorReason = errorReason {
            let alert = UIAlertController(title: "Error", message: errorReason, preferredStyle: .alert)
            alert.addOKButton(nil)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: LogisticsManagerLocationDelegate
    
    open func manager(_ manager: LocationManager, didReceiveFirst location: CLLocationCoordinate2D) {
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView?.setRegion(region, animated: true)
        manager.getLocationData(forCoordinates: location) { locationData in
            if let locationLabel = self.locationLabel {
                locationLabel.text = "\(locationData.city), \(locationData.state), \(locationData.country)"
            }
        }
    }
}

