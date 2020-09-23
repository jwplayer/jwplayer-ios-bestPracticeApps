//
//  AutoplayVideoFeedViewController.swift
//  AutoplayVideoFeed
//
//  Created by Stephen Seibert  on 3/31/20.
//  Copyright © 2020 Karim Mourra. All rights reserved.
//

import UIKit

class AutoplayVideoFeedViewController: FeedTableViewController {
    
    override func fetchFeed() {
        guard let feedFilePath = Bundle.main.path(forResource: "Feed", ofType: "plist"),
            let feedInfo = NSArray(contentsOfFile: feedFilePath) as? [Dictionary<String, String>] else {
            return
        }
        
        // Populate the feed array with video players
        for itemInfo in feedInfo {
            guard let url = itemInfo["url"], let title = itemInfo["title"], let thumbnail = itemInfo["localThumbnail"] else {
                continue
            }

            if let player = buildPlayer(title: title, url: url, thumbnail: thumbnail) {
                feed.append(player)
            }
        }
    }
    
    
    func buildPlayer(title: String, url: String, thumbnail: String) -> JWPlayerController? {
        // We wish to show a video on a UITableCell, and have it play silently when
        // on the screen. The controls are disabled to prevent the user from
        // changing this state of the video in this example, since we begin them automatically.
        // We also add a thumbnail to load while the video autoplays.
        if let player = buildPlayer(title: title, url: url) {
            player.config.controls = false
            player.config.image = thumbnail
            // The volume is muted because in this example we play the videos automatically,
            // and do not want multiple videos to play their audio at the same time,
            // which would be unpleasant.
            player.volume = 0.0
            return player
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedItemCellIdentifier, for: indexPath) as! FeedItemCell
        
        // Add player view to the container view of the cell
        cell.player = feed[indexPath.row]
        
        // Search for the title on the thumbnails Array and add the corresponding image
        guard let thumbnailName = cell.player?.config.image else { return cell }
        cell.thumbnailImageView.image = UIImage(named: thumbnailName)
                
        return cell
    }
}
