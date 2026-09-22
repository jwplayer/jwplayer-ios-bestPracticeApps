//
//  AppDelegate.swift
//  CNX Ad Server
//

import UIKit
import JWPlayerKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // The license key comes from CNXConfig, like every other publisher value in this app.
        // If the config is incomplete, SceneDelegate shows what is missing instead of a player.
        if CNXConfig.validate().isEmpty {
            JWPlayerKitLicense.setLicenseKey(CNXConfig.licenseKey)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
