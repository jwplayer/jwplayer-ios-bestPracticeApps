//
//  OfflinePlayLoaderViewController.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/22/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation
import UIKit
import JWPlayerKit

/// A convenience UIViewController which has a JWPlayerViewController embedded within it
/// and creates a config with the supplied player item.
class OfflinePlayLoaderViewController: UIViewController {
    /// When this controll is created, this property must be set so the config can be created.
    internal var item: JWPlayerItem?
    
    /// A convenience property for accessing the player instance.
    private var player: JWPlayerProtocol? {
        for vc in children {
            guard let vc = vc as? JWPlayerViewController else {
                continue
            }
            
            return vc.player
        }
        
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Create the config.
        guard let item,
              let config = try? JWPlayerConfigurationBuilder()
            .playlist(items: [item])
            .build() else {
            return
        }
        
        /// Initialize the player with the config.
        player?.configurePlayer(with: config)
    }
}
