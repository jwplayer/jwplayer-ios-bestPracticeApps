//
//  FeedItemCell.swift
//  FeedTableViewController
//
//  Created by Amitai Blickstein on 6/26/22.
//

import UIKit
import JWPlayerKit

class PlayerItemCell: UITableViewCell {
    static let reuseIdentifier = "PlayerItemCell"
    static let nibName         = "PlayerItemCell"
            
    /// The view (UIView subclass) underlying this View (in the MVVM sense)
    @IBOutlet weak var playerView: JWPlayerView!
    /// Shows the video # in the array, to make it clear that the feed is "infinite".
    @IBOutlet weak var descriptionLabel: UILabel!
    /// The video title. Obtained from your video provider solution.
    @IBOutlet weak var titleLabel: UILabel!

    /// Provided by viewModel.
    /// - note: Loads the cell's player with the new item when assigned.
    var item: JWPlayerItem? {
        willSet { loadCellPlayer(with: newValue) }
    }
    
    /// Determines if the player item should autostart.
    var autostart: Bool = false

    /// Loads the cell's player using the relatively inexpensive `loadPlaylist` API.
    private func loadCellPlayer(with item: JWPlayerItem?) {
        guard let item,
              let config = getPlayerConfig(for: item) else {
            return
        }

        titleLabel.text = item.title
        playerView.videoGravity = .resizeAspectFill
    
        if playerNeedsToBeConfigured() {
            playerView.player.configurePlayer(with: config)
        } else {
            playerView.player.loadPlaylist(items: [item])
        }
    }
    
    /// If the player has not been initialized yet, or is stuck in an unrecoverable error state,
    /// then `configure` is needed. Otherwise, calling `loadPlaylist` is the performant way to play
    /// a new asset without expensive player creation.
    /// - Returns: Returns `true` if the player is in the `error` or `unknown` states.
    private func playerNeedsToBeConfigured() -> Bool {
        [.unknown, .error]
            .contains(playerView.player.getState())
    }
    
    private func getPlayerConfig(for item: JWPlayerItem?) -> JWPlayerConfiguration? {
        guard let item else {
            return nil
        }

        return try? JWPlayerConfigurationBuilder()
            .playlist(items: [item])
            .autostart(autostart)
            .preload(.auto)
            .repeatContent(true)
            .build()
    }
}
