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

public struct LocationManagerConstantKeys {
    static let cityKey = "com.ibm.cloud.LogisticsWizardMobile.LocationManagerConstantKeys.CityKey"
    static let stateKey = "com.ibm.cloud.LogisticsWizardMobile.LocationManagerConstantKeys.StateKey"
    static let countryKey = "com.ibm.cloud.LogisticsWizardMobile.LocationManagerConstantKeys.CountryKey"
    static let latitudeKey = "com.ibm.cloud.LogisticsWizardMobile.LocationManagerConstantKeys.LatitudeKey"
    static let longitudeKey = "com.ibm.cloud.LogisticsWizardMobile.LocationManagerConstantKeys.LongitudeKey"
    static let forceDefaultLocationKey = "com.ibm.cloud.LogisticsWizardMobile.LocationManagerConstantKeys.ForceDefaultLocationKey"
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
        geocoder.reverseGeocodeLocation(CLLocation(latitude: forCoordinates.latitude, longitude: forCoordinates.longitude)) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    completion(self.fakeLocationData())
                }
                if let placemarks = placemarks, let placemark = placemarks.first, let addressDictionary = placemark.addressDictionary {
                    guard let country = placemark.country, let state = placemark.administrativeArea, let city = addressDictionary["City"] as? String else {
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
