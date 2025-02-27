//
//  ViewController.swift
//  BasicTVPlayer
//
//  Created by JW Player.
//

import UIKit
import JWPlayerTVKit

/**
 Provides minimal setup for a JWCinematicViewController.
 */
class BasicPlayerViewController: JWCinematicViewController {

    private let videoUrlString = "https://playertest.longtailvideo.com/adaptive/bbbfull/bbbfull.m3u8"
    private let posterUrlString = "https://assets-jpcust.jwpsrv.com/thumbnails/to6w2sch-720.jpg"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the player
        setUpPlayer()
    }

    /**
     Sets up the player with a simple configuration.
     */
    private func setUpPlayer() {
        do {
            // First, build a player item with the stream URL
            let item = try JWPlayerItemBuilder()
                .title("Big Buck Bunny")
                .description("Big Buck Bunny (code-named Project Peach) is a 2008 short computer-animated comedy film featuring animals of the forest, made by the Blender Institute, part of the Blender Foundation. Like the foundation's previous film, Elephants Dream, the film was made using Blender, a free and open-source software application for 3D computer modeling and animation developed by the same foundation.")
                .file(URL(string: videoUrlString)!)
                .posterImage(URL(string: posterUrlString)!)
                .build()

            // Second, build a player configuration using the player item
            let config = try JWPlayerConfigurationBuilder()
				.playlist(items: [item])
                .build()
            
            // Last, configure the player
            player.configurePlayer(with: config)
        } catch {
            // Handle builder failure
            print(error.localizedDescription)
        }
    }

    /**
     This method is called when the player is fully initialized.
     */
    override func jwplayerIsReady(_ player: JWPlayer) {
        print("The player is ready")
    }

    /**
     This method is called when the player encounters an error during setup and initialization.
     */
    override func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        print("An error occurred during player setup: [\(code)] \(message)")
    }

    /**
     This method is called when the player encounters an error with playback.
     */
    override func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        print("A playback error occurred: [\(code)] \(message)")
    }

    /**
     This method is called when the player encounters a warning within the SDK.
     */
    override func jwplayer(_ player: JWPlayer, encounteredWarning code: UInt, message: String) {
        print("Warning: [\(code)] \(message)")
    }

}

