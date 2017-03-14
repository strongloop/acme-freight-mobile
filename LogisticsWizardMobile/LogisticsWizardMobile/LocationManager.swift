//
//  LocationManager.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 3/14/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit
import CoreLocation

protocol LogisticsLocationManagerDelegate {
    func manager(_ manager: LocationManager, didReceiveFirst location: CLLocationCoordinate2D)
}

public struct LocationData {
    var city: String
    var state: String
    var country: String
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    public var lastLoggedLocation: CLLocation?
    var delegate: LogisticsLocationManagerDelegate?
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        if let manager = self.locationManager {
            manager.requestAlwaysAuthorization()
            manager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                manager.delegate = self
                manager.desiredAccuracy = kCLLocationAccuracyBest
                lastLoggedLocation = nil
                manager.startUpdatingLocation()
            }
        }
    }
    
    // MARK: Location Manager Delegate Methods
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            if let location = manager.location {
                defer {
                    self.lastLoggedLocation = location
                }
                if self.lastLoggedLocation == nil {
                    guard let delegate = self.delegate else {
                        return
                    }
                    self.lastLoggedLocation = location
                    delegate.manager(self, didReceiveFirst: location.coordinate)
                }
            }
        }
    }
    
    public func getLocationData(forCoordinates: CLLocationCoordinate2D, _ completion: @escaping (_ data: LocationData) -> Void) {
        let geocoder = CLGeocoder()
        guard let lastLoggedLocation = lastLoggedLocation else {
            completion(fakeLocationData())
            return
        }
        geocoder.reverseGeocodeLocation(lastLoggedLocation) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    completion(self.fakeLocationData())
                }
                if let placemarks = placemarks, let placemark = placemarks.first {
                    guard let country = placemark.country, let state = placemark.administrativeArea, let city = placemark.subAdministrativeArea else {
                        completion(self.fakeLocationData())
                        return
                    }
                    completion(LocationData(city: city, state: state, country: country))
                }
            }
        }
    }
    
    private func fakeLocationData() -> LocationData {
        return LocationData(city: "Bismarck", state: "North Dakota", country: "USA")
    }
}
