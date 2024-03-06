//
//  ViewController.swift
//  Picture in Picture
//
//  Created by David Almaguer on 23/05/22.
//

import UIKit
import AVKit
import JWPlayerKit

class ViewController: UIViewController {

    @IBOutlet weak var pipButton: UIBarButtonItem!
    weak var playerVC: JWPlayerViewController?

    private let videoUrlString = "https://playertest.longtailvideo.com/adaptive/bbbfull/bbbfull.m3u8"
    private let posterUrlString = "https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"
    private var pipPossibleObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Once view is loaded, create an observer to monitor whether or not Picture in Picture is currently available.
        pipPossibleObservation = playerVC?.playerView.pictureInPictureController?.observe(\AVPictureInPictureController.isPictureInPicturePossible, options: [.initial, .new]) { [weak self] _, change in
            // Make changes depending on whether Picture in Picture is possible or not, such as enabling a button to toggle Picture in Picture mode.
            self?.pipButton.isEnabled = change.newValue ?? false
        }
    }
    
    deinit {
        pipPossibleObservation = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If we are loading the PlayerViewController, we create a config and hand it off.
        switch segue.destination {
        case let vc as PlayerViewController:
            let videoUrl = URL(string:videoUrlString)!
            let posterUrl = URL(string:posterUrlString)!

            // Open a do-catch block to handle possible errors with the builders.
            do {
                // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
                let playerItem = try JWPlayerItemBuilder()
                    .file(videoUrl)
                    .posterImage(posterUrl)
                    .build()

                // Second, create a player config with the created JWPlayerItem and JWAdvertisingConfig
                let config = try JWPlayerConfigurationBuilder()
                    .playlist(items: [playerItem])
                    .autostart(true)
                    .build()

                // Third, use the created JWPlayerConfiguration to set up the player.
                vc.config = config

                // Lastly, store the current player view controller
                playerVC = vc
            } catch {
                print(error.localizedDescription)
                return
            }
            break
        default:
            break
        }
    }

    @IBAction func pipButtonTapped(_ sender: UIBarButtonItem) {
        guard let pipController = playerVC?.playerView.pictureInPictureController else {
            return
        }
        if !pipController.isPictureInPictureActive {
            pipController.startPictureInPicture()
        } else {
            pipController.stopPictureInPicture()
        }
    }

}

