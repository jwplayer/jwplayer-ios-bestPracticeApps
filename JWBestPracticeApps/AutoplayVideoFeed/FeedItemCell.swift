//
//  FeedItemCell.swift
//  AutoplayVideoFeed
//
//  Created by Stephen Seibert  on 3/31/20.
//  Copyright © 2020 Karim Mourra. All rights reserved.
//

import UIKit

let FeedItemCellDefaultHeight: CGFloat = 300
let FeedItemCellIdentifier: String = "FeedItemCell"

class FeedItemCell: UITableViewCell, JWPlayerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    weak var player: JWPlayerController? {
        willSet {
            player?.pause()
            player?.delegate = nil
            player?.view?.removeFromSuperview()
        }

        didSet {
            guard let player = player, let playerView = player.view else {
                return
            }
            
            containerView.addSubview(playerView)
            containerView.isUserInteractionEnabled = false
            playerView.constraintToSuperview()
            
            // To avoid lag in video load show the local thumbnail before the player starts playing
            if player.state == .idle {
                containerView.bringSubviewToFront(thumbnailImageView)
                thumbnailImageView.isHidden = false
            } else {
                // Hide the local thumbnail if the player has started
                thumbnailImageView.isHidden = true
            }

            player.play()
            player.delegate = self
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.delegate = nil
    }

    override var reuseIdentifier: String? {
        return FeedItemCellIdentifier
    }
    
    // When the player starts, hide the local thumbnail
    func onFirstFrame(_ event: JWEvent & JWFirstFrameEvent) {
        thumbnailImageView.isHidden = true
    }

    func onReady(_ event: JWEvent & JWReadyEvent) {
        player?.play()
    }
}
