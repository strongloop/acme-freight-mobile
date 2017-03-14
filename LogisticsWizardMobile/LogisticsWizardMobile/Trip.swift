//
//  Trip.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 3/14/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit
import CoreLocation

private extension String {
    var dateFromISO8601: Date? {
        return Date.iso8601Formatter.date(from: self)
    }
}

private extension Date {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
}

class Trip: NSObject {
    var latitude: Double
    var longitude: Double
    var city: String
    var state: String
    var country: String
    
    init(locationData: LocationData, coordinates: CLLocationCoordinate2D) {
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
        self.city = locationData.city
        self.state = locationData.state
        self.country = locationData.country
    }
    
    var json: [String: Any]? {
        if let arrival = Calendar.current.date(byAdding: .day, value: 2, to: Date()) {
            return ["data" : ["status" : "IN_TRANSIT", "createdAt" : Date().iso8601, "estimatedTimeOfArrival" : arrival.iso8601, "fromId" : 3, "toId" : 3, "currentLocation" : ["city" : city, "state" : state, "country" : country, "latitude" : latitude, "longitude" : longitude]]]
        } else {
            return nil
        }
    }
}
