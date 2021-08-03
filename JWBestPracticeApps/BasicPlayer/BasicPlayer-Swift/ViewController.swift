//
//  ViewController.swift
//  BasicPlayer-Swift
//
//  Created by Michael Salvador on 8/2/21.
//

import UIKit
import JWPlayerKit

/**
 Provides minimal setup for a JWPlayerViewController.
 */
class ViewController: JWPlayerViewController {

    private let videoUrlString = "https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8"
    private let posterUrlString = "https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"

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

        // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
        let playerItembuilder = JWPlayerItemBuilder()
            .file(videoUrl)
            .posterImage(posterUrl)
        var playerItem: JWPlayerItem!
        do {
            playerItem = try playerItembuilder.build()
        } catch {
            // Handle player item build failure
            print(error.localizedDescription)
            return
        }

        // Second, create a player config with the created JWPlayerItem.
        let configBuilder = JWPlayerConfigurationBuilder()
            .playlist([playerItem])
            .autostart(true)
        var config: JWPlayerConfiguration!
        do {
            config = try configBuilder.build()
        } catch {
            // Handle player item build failure
            print(error.localizedDescription)
            return
        }

        // Lastly, use the created JWPlayerConfiguration to set up the player.
        player.configurePlayer(with: config)
    }
}

