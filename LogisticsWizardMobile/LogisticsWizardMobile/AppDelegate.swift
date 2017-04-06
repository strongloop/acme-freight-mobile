//
//  AppDelegate.swift
//  LogisticsWizardMobile
//
//  Created by David Okun IBM on 3/8/17.
//  Copyright © 2017 David Okun IBM. All rights reserved.
//

import UIKit

public struct EnvVarConstantKeys {
    static let requiresGUID = "com.ibm.cloud.LogisticsWizardMobile.SessionConstants.CurrentSession.requiresGUID"
    static let defaultOpenWhiskToken = "ODAzMDIzNjEtYzkxNy00Y2JkLTlkYzUtZTExMzc1ZGQwMDk3Om1zVVlpZU95NkJqTXlYQ0xPNXQyNTZSNDRjeHZpYnBpaE9qQlI2ZUdMY0V0YWhJVkNHT2EyTDUwdXRYQlhEUEg="
    static let defaultHostURL = "https://openwhisk.ng.bluemix.net/api/v1/namespaces/svennam%40us.ibm.com_acme-freight/actions/create-shipment-test"
    static let defaultLatitude = "46.825905"
    static let defaultLongitude = "-100.778275"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent
        customizeNavBar(UIColor.white)

        UserDefaults.standard.set(EnvVarConstantKeys.defaultOpenWhiskToken, forKey: WebAPIConstantKeys.openWhiskToken)
        UserDefaults.standard.set(EnvVarConstantKeys.defaultHostURL, forKey: WebAPIConstantKeys.hostURL)
        UserDefaults.standard.set(true, forKey: EnvVarConstantKeys.requiresGUID)
        
        return true
    }
    
    func customizeNavBar(_ color: UIColor) {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: color]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: color], for: .normal)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        resetGUIDRequired()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        resetGUIDRequired()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func resetGUIDRequired() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: EnvVarConstantKeys.requiresGUID)
        defaults.synchronize()
    }
}

