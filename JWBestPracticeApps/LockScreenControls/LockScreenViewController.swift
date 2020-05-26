//
//  LockScreenViewController.swift
//  LockScreenControls
//
//  Created by Michael Salvador on 5/25/20.
//  Copyright © 2020 Karim Mourra. All rights reserved.
//

import UIKit

class LockScreenViewController: UIViewController {

    var topPlayer: JWPlayerController!
    var bottomPlayer: JWPlayerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        createTopPlayer()
        createBottomPlayer()

        // After all players have been instantiated, make sure 'displayLockScreenControls' is set to false for all the players
        // you don't want to be affected by lock screen controls. Then, set 'displayLockScreenControls' true
        // for the player you do want the lock screen controls to affect.

        bottomPlayer.displayLockScreenControls = false // Won't be affected by lock screen controls
        topPlayer.displayLockScreenControls = true // Will be affected by lock screen controls

        // Note: - If a third player is instantiated, it will take over the current lock screen controls,
        // because 'displayLockScreenControls' defaults to true.
    }

    func createTopPlayer() {
        let videoURL = "http://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8"
        let posterImageURL = "http://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"
        let config = JWConfig.init(contentUrl: videoURL)
        config.image = posterImageURL
        config.title = "Top Player"
        config.autostart = true
        config.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.height/2)
        self.topPlayer = JWPlayerController(config: config)
        if let playerView = self.topPlayer.view {
            self.view.addSubview(playerView)
            let midX = self.view.frame.midX
            let midY = self.view.frame.midY
            playerView.center = CGPoint(x: midX, y: midY - (config.size.height/2))
        }
    }

    func createBottomPlayer() {
        let videoURL = "https://playertest.longtailvideo.com/adaptive/bipbop/bipbopall.m3u8"
        let posterImageURL = "http://d3el35u4qe4frz.cloudfront.net/3XnJSIm4-480.jpg"
        let config = JWConfig.init(contentUrl: videoURL)
        config.image = posterImageURL
        config.title = "Bottom Player"
        config.autostart = true
        config.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height/2)
        self.bottomPlayer = JWPlayerController(config: config)
        if let playerView = self.bottomPlayer.view {
            self.view.addSubview(playerView)
            let midX = self.view.frame.midX
            let midY = self.view.frame.midY
            playerView.center = CGPoint(x: midX, y: midY + (config.size.height/2))
        }
    }
}

