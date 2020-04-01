//
//  AutoplayVideoFeedViewController.swift
//  AutoplayVideoFeed
//
//  Created by Stephen Seibert  on 3/31/20.
//  Copyright © 2020 Karim Mourra. All rights reserved.
//

import UIKit

class AutoplayVideoFeedViewController: UITableViewController {

    var feed = [JWPlayerController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchFeed()
    }

    fileprivate func fetchFeed() {
        guard let feedFilePath = Bundle.main.path(forResource: "Feed", ofType: "plist"),
            let feedInfo = NSArray(contentsOfFile: feedFilePath) as? [Dictionary<String, String>] else {
            return
        }

        // Populate the feed array with video players
        for itemInfo in feedInfo {
            guard let url = itemInfo["url"] else {
                continue
            }

            // We wish to show a video on a UITableCell, and have it play silently when
            // on the screen. The controls are disabled to prevent the user from
            // changing this state of the video in this example, since we begin them automatically.
            let config = JWConfig(contentUrl: url)
            config.controls = false
            config.image = "https://professional.brown.edu/wp-content/uploads/2017/07/jw-player-logo.jpg"

            if let player = JWPlayerController(config: config) {
                player.config.title = itemInfo["title"]

                // The volume is muted because in this example we play the videos automatically,
                // and do not want multiple videos to play their audio at the same time,
                // which would be unpleasant.
                player.volume = 0.0
                feed.append(player)
            }
        }
    }

// MARK: UITableViewDataSource implementation

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (feed.count > 0) ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FeedItemCellDefaultHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedItemCellIdentifier, for: indexPath) as! FeedItemCell

        let player = feed[indexPath.row]

        // Add player view to the container view of the cell
        cell.player = player

        return cell
    }
}
