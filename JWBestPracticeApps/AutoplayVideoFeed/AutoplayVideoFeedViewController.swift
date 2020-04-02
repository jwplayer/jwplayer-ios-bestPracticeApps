//
//  AutoplayVideoFeedViewController.swift
//  AutoplayVideoFeed
//
//  Created by Stephen Seibert  on 3/31/20.
//  Copyright © 2020 Karim Mourra. All rights reserved.
//

import UIKit

class AutoplayVideoFeedViewController: FeedTableViewController {

    override func buildPlayer(title: String, url: String) -> JWPlayerController? {
        // We wish to show a video on a UITableCell, and have it play silently when
        // on the screen. The controls are disabled to prevent the user from
        // changing this state of the video in this example, since we begin them automatically.
        let config = JWConfig(contentUrl: url)
        config.controls = false

        if let player = JWPlayerController(config: config) {
            player.config.title = title

            // The volume is muted because in this example we play the videos automatically,
            // and do not want multiple videos to play their audio at the same time,
            // which would be unpleasant.
            player.volume = 0.0
            return player
        }
        return nil
    }
}
