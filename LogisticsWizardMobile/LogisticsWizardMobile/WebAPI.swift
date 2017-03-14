//
//  WebAPI.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 3/14/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit

private struct WebAPIParams {
    static var hostURL: URL? {
        guard let urlString = UserDefaults.standard.string(forKey: WebAPIConstantKeys.hostURLKey) else {
            return nil
        }
        return URL(string: urlString)
    }
    
    static var openWhiskToken: String? {
        return UserDefaults.standard.string(forKey: WebAPIConstantKeys.openWhiskTokenKey)
    }
}

public struct WebAPIConstantKeys {
    static let hostURLKey = "com.ibm.cloud.LogisticsWizardMobile.hostURLKey"
    static let openWhiskTokenKey = "com.ibm.cloud.LogisticsWizardMobile.openWhiskToken"
}

private enum WebAPIError: Error {
    case noHostSpecified
    case noTokenSpecified
    case badParameters
    case other(reason: String)
}

class WebAPI: NSObject {
    class func register(_ trip: Trip, _ completion: @escaping (_ shipmentID: Int?, _ errorMessage: String?) -> Void) {
        do {
            guard let authToken = WebAPIParams.openWhiskToken else {
                throw WebAPIError.noTokenSpecified
            }
            let headers = ["Content-Type" : "application/json", "Authorization" : "Basic " + authToken]
            guard let parameters = trip.json else {
                throw WebAPIError.badParameters
            }
            let postData =  try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            guard let url = WebAPIParams.hostURL else {
                throw WebAPIError.noHostSpecified
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            URLSession.shared.dataTask(with: request, completionHandler: { data, urlResponse, error in
                if let error = error {
                    completion(nil, error.localizedDescription)
                } else {
                    do {
                        guard let data = data else {
                            completion(nil, "")
                            return
                        }
                        guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject] else {
                            completion(nil, "Could not parse response")
                            return
                        }
                        guard let response = json["response"] as? [String : Any] else {
                            completion(nil, "Could not parse response")
                            return
                        }
                        guard let result = response["result"] as? [String : Any] else {
                            completion(nil, "Could not parse response")
                            return
                        }
                        guard let resultData = result["data"] as? [String : Any] else {
                            completion(nil, "Could not parse response")
                            return
                        }
                        guard let shipmentID = resultData["id"] as? Int else {
                            completion(nil, "Could not parse response")
                            return
                        }
                        guard let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                            completion(nil, "Could not parse response")
                            return
                        }
                        completion(shipmentID, nil)
                    } catch {
                        
                    }
                }
            }).resume()
        } catch WebAPIError.noHostSpecified {
            completion(nil, "No host URL specified")
        } catch WebAPIError.noTokenSpecified {
            completion(nil, "No OpenWhisk token specified")
        } catch WebAPIError.other(let errorReason) {
            completion(nil, errorReason)
        } catch {
            completion(nil, "Uncaught exception")
        }
    }
}
