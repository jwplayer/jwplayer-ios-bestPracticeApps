//
//  PlayerViewController.swift
//  Picture in Picture
//
//  Created by David Almaguer on 24/05/22.
//

import UIKit
import AVKit
import JWPlayerKit

class PlayerViewController: JWPlayerViewController {

    var config: JWPlayerConfiguration!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let config else {
            fatalError("A player config should be specified.")
        }
        
        player.configurePlayer(with: config)
    }

    // Reports when Picture in Picture is about to start.
    override func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        super.pictureInPictureControllerWillStartPictureInPicture(pictureInPictureController)
    }

    // Reports when Picture in Picture playback has started.
    override func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        super.pictureInPictureControllerDidStartPictureInPicture(pictureInPictureController)
    }

    // Reports when Picture in Picture failed to start.
    override func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        super.pictureInPictureController(pictureInPictureController, failedToStartPictureInPictureWithError: error)
    }

    // Reports when Picture in Picture playback is about to stop.
    override func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        super.pictureInPictureControllerWillStopPictureInPicture(pictureInPictureController)
    }

    // Reports when Picture in Picture is about to stop, to give your app an opportunity to restore its video playback user interface.
    override func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Restore the user interface before Picture in Picture stops.

        // MARK: - IMPORTANT-
        // Make sure to call the super method when you have restored the UI, it is important to notify the system of this.
        super.pictureInPictureController(pictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler)
    }

    // Reports when Picture in Picture playback stops.
    override func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        super.pictureInPictureControllerDidStopPictureInPicture(pictureInPictureController)
    }
}
