//
//  ViewController.swift
//  ChromeCast
//
//  Created by Stephen Seibert on 8/10/21.
//

import UIKit
import JWPlayerKit

class ViewController: JWPlayerViewController {
    
    private let videoUrlString = "https://cdn.jwplayer.com/videos/CXz339Xh-sJF8m8CA.mp4"
    private let posterUrlString = "https://cdn.jwplayer.com/thumbs/CXz339Xh-720.jpg"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's background color to black for better contrast.
        view.backgroundColor = .black

        // Set up the player.
        setUpPlayer()
    }

    /**
     Sets up the player with a simple configuration.
     */
    private func setUpPlayer() {
        let videoUrl = URL(string:videoUrlString)!
        let posterUrl = URL(string:posterUrlString)!
        
        do {
            // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
            let playerItem = try JWPlayerItemBuilder()
                .file(videoUrl)
                .posterImage(posterUrl)
                .build()
            
            // Second, create a player config with the created JWPlayerItem. Add the related config.
            let config = try JWPlayerConfigurationBuilder()
                .playlist([playerItem])
                .autostart(true)
                .build()
            
            // Lastly, use the created JWPlayerConfiguration to set up the player.
            player.configurePlayer(with: config)
        } catch {
            // Handle player item build failure
            print(error.localizedDescription)
            return
        }
    }

}

