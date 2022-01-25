//
//  AppDelegate.swift
//  BasicPlayer-Swift
//
//  Created by Michael Salvador on 8/2/21.
//

import UIKit
import JWPlayerKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Add your JW Player license key.
        JWPlayerKitLicense.setLicenseKey("XESWDHH3RTkYqna+1TNpjWbJpQIES/MRY9CoJvIxVYL795nYoVE4w8yJX4Xq80rF9CJ28CgxKKB2ZEv7")
        // JWPlayerKitLicense.setLicenseKey( )

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

