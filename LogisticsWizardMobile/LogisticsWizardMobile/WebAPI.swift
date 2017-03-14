//
//  WebAPI.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 3/14/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit

class WebAPI: NSObject {
    class func register(_ trip: Trip, _ completion: @escaping (_ success: Bool) -> Void) {
        do {
            let headers = ["Content-Type" : "application/json", "Authorization" : "Basic ODAzMDIzNjEtYzkxNy00Y2JkLTlkYzUtZTExMzc1ZGQwMDk3Om1zVVlpZU95NkJqTXlYQ0xPNXQyNTZSNDRjeHZpYnBpaE9qQlI2ZUdMY0V0YWhJVkNHT2EyTDUwdXRYQlhEUEg="]
            guard let parameters = trip.json else {
                completion(false)
                return
            }
            let postData =  try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            guard let url = URL(string: "https://openwhisk.ng.bluemix.net/api/v1/namespaces/svennam%40us.ibm.com_acme-freight/actions/create-shipment?blocking=true") else {
                completion(false)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let _ = error {
                    completion(false)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(false)
                        return
                    }
                    completion(httpResponse.statusCode == 200)
                }
            }).resume()
        } catch {
            completion(false)
        }
    }
}
