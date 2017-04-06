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

public struct TripParameterConstantKeys {
    static let guidPersistence = "com.ibm.cloud.LogisticsWizardMobile.SessionConstants.CurrentSession.guid"
    static let guid = "guid"
    static let data = "data"
    static let status = "status"
    static let inTransit = "IN_TRANSIT"
    static let createdAt = "createdAt"
    static let estimatedTimeOfArrival = "estimatedTimeOfArrival"
    static let fromId = "fromId"
    static let toId = "toId"
    static let currentLocation = "currentLocation"
    static let city = "city"
    static let state = "state"
    static let country = "country"
    static let latitude = "latitude"
    static let longitude = "longitude"
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
        guard let arrival = Calendar.current.date(byAdding: .day, value: 2, to: Date()) else { return nil }
        let guid = UserDefaults.standard.integer(forKey: TripParameterConstantKeys.guidPersistence)
        if String(guid).characters.count != 4 { return nil }
        if UserDefaults.standard.bool(forKey: WebAPIConstantKeys.shouldUseDefaultLocation) {
            latitude = UserDefaults.standard.double(forKey: WebAPIConstantKeys.defaultLatitude)
            longitude = UserDefaults.standard.double(forKey: WebAPIConstantKeys.defaultLongitude)
        }
        return [TripParameterConstantKeys.guid : guid,
                TripParameterConstantKeys.data :
                    [TripParameterConstantKeys.status : TripParameterConstantKeys.inTransit,
                     TripParameterConstantKeys.createdAt : Date().iso8601,
                     TripParameterConstantKeys.estimatedTimeOfArrival : arrival.iso8601,
                     TripParameterConstantKeys.fromId : 3,
                     TripParameterConstantKeys.toId : 3,
                     TripParameterConstantKeys.currentLocation :
                        [TripParameterConstantKeys.city : city,
                         TripParameterConstantKeys.state : state,
                         TripParameterConstantKeys.country : country,
                         TripParameterConstantKeys.latitude : latitude,
                         TripParameterConstantKeys.longitude : longitude]]]
    }
}
