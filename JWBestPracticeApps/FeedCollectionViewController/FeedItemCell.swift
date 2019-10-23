//
//  FeedItemCell.swift
//  FeedCollectionViewController
//
//  Created by Michael Salvador on 10/15/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit

class FeedItemCell: UICollectionViewCell {
    
    @IBOutlet var containerView: UIView!
    
    weak var player: JWPlayerController? {
        didSet {
            player?.delegate = self
            // Add player view to the container view of the cell and fill it
            if let playerView = player?.view {
                // The container view is centered in the cell in the storyboard
                containerView.addSubview(playerView)
                playerView.constraintToSuperview()
            }
        }
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
