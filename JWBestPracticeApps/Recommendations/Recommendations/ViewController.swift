//
//  ViewController.swift
//  Recommendations
//
//  Created by Stephen Seibert on 8/10/21.
//

import UIKit
import JWPlayerKit

/**
 Provides minimal setup for a JWPlayerViewController.
 */
class ViewController: JWPlayerViewController {
    
    private let videoUrlString = "https://cdn.jwplayer.com/videos/CXz339Xh-sJF8m8CA.mp4"
    private let posterUrlString = "https://cdn.jwplayer.com/thumbs/CXz339Xh-720.jpg"
    private let recommendationsString = "https://playertest.longtailvideo.com/related/three_item_feed.json"

    // Use this property to switch between global or player item recommendations.
    private var useRecPerPlayerItem = true

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
        let recommendationsUrl = URL(string: recommendationsString)!
        
        do {
            // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
            // Add a URL to the recommendations feed. This will cause the recommendations menu to become available.
            let playerItemBuilder = JWPlayerItemBuilder()
                .file(videoUrl)
                .posterImage(posterUrl)
            
            // Second, create a JWRelatedContentConfiguration and set what to do on completion.
            // You have a few options, including showing the screen, or displaying a countdown until the next item plays.
            let relatedConfigBuilder = JWRelatedContentConfigurationBuilder()
                .onComplete(.none)
                .autoplayTimer(5)

            // Configure recommendations either global or per player item.
            if useRecPerPlayerItem {
                playerItemBuilder.recommendations(recommendationsUrl)
            } else {
                relatedConfigBuilder.url(recommendationsUrl)
            }

            let playerItem = try playerItemBuilder.build()
            let relatedConfig = relatedConfigBuilder.build()

            // Second, create a player config with the created JWPlayerItem. Add the related config.
            let config = try JWPlayerConfigurationBuilder()
                .playlist([playerItem])
                .autostart(true)
                .related(relatedConfig)
                .build()
            
            // Third, optionally, configure whether these recommendations items play after the playlist is complete,
            // configure a NextUpStyle object and supply it to the ViewController. You can control when to display
            // a Next Up Card at the top of the screen when the content nears completion.
            let nextUpStyle = try JWNextUpStyleBuilder()
                .timeOffset(seconds: -5)    // A negative number counts back from the end of the content.
                .build()
            self.nextUpStyle = nextUpStyle
            
            // Lastly, use the created JWPlayerConfiguration to set up the player.
            player.configurePlayer(with: config)
        } catch {
            // Handle player item build failure
            print(error.localizedDescription)
            return
        }
    }
}

