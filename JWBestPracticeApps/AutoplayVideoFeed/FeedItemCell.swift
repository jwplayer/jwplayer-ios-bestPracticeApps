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

    var player: JWPlayerController? {
        willSet {
            player?.pause()
            player?.delegate = nil
            player?.view?.removeFromSuperview()
        }

        didSet {
            guard let playerView = player?.view else {
                return
            }

            containerView.addSubview(playerView)
            containerView.isUserInteractionEnabled = false
            playerView.constraintToSuperview()

            player?.play()
            player?.delegate = self
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        player?.delegate = nil
    }

    override var reuseIdentifier: String? {
        return FeedItemCellIdentifier
    }

    func onReady(_ event: JWEvent & JWReadyEvent) {
        player?.play()
    }
}

// MARK: Helper method

extension UIView {

    public func constraintToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[thisView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])

        let verticalConstraints   = NSLayoutConstraint.constraints(withVisualFormat: "V:|[thisView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["thisView": self])

        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
    }
}
