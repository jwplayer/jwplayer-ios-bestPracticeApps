//
//  SceneDelegate.swift
//  CNX Ad Server
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Fail loudly: with an incomplete config, no player is ever set up. The error screen names
        // each missing or wrong value instead of leaving you with a player that never shows ads.
        let problems = CNXConfig.validate()
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = problems.isEmpty
            ? UINavigationController(rootViewController: ViewController())
            : ConfigErrorViewController(problems: problems)
        window.makeKeyAndVisible()
        self.window = window
    }
}
