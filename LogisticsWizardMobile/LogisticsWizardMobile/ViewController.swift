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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = "466BB0".hexColor
        navigationController?.navigationBar.isTranslucent = false
        let logo = UIImage(named: "API Connect_logo_white")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        imageView.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        navigationItem.titleView = imageView
        locationManager = LocationManager()
        if let locationManager = locationManager {
            locationManager.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let button = registerTripButton else {
            return
        }
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        button.layer.shadowOffset = CGSize(width: 1.0, height: 3.0)
        button.layer.shadowOpacity = 0.65
        button.layer.shadowRadius = 3.0
        button.layer.cornerRadius = 3.0
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
        button.isEnabled = false
        button.setTitle("Registering trip", for: .normal)
        locationManager.getLocationData(forCoordinates: location.coordinate) { data in
            defer {
                button.isEnabled = true
            }
            let trip = Trip(locationData: data, coordinates: location.coordinate)
            WebAPI.register(trip, { success in
                print("update UI now")
            })
        }
    }
    
    // MARK: LogisticsManagerLocationDelegate
    
    func manager(_ manager: LocationManager, didReceiveFirst location: CLLocationCoordinate2D) {
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView?.setRegion(region, animated: true)
    }
}

