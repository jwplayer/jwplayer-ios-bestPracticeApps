//
//  FeedCollectionViewController.swift
//  FeedCollectionViewController
//
//  Created by Michael Salvador on 10/15/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit

class FeedCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // The data that will appear in the collection view
    var feed = [JWPlayerController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFeed()
    }

    // Gets the information for the players that will appear in the collection view
    private func fetchFeed() {
        guard let feedFilePath = Bundle.main.path(forResource: "Feed", ofType: "plist"),
              let feedInfo = NSArray(contentsOfFile: feedFilePath) as? [Dictionary<String, String>] else {
            return
        }

        // Populate the feed array with video players
        for itemInfo in feedInfo {
            guard let url = itemInfo["url"] else {
                continue
            }
    
            if let player = JWPlayerController(config: JWConfig(contentURL: url)) {
                player.config.title = itemInfo["title"]
                feed.append(player)
            }
        }
    }

// MARK: UICollectionViewDataSource implementation

    override func numberOfSections(in: UICollectionView) -> Int {
        return (feed.count > 0) ? 1 : 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feed.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FeedItemCell

        // Get player from the feed array
        let player = feed[indexPath.row]

        // Add player view to the container view of the cell and fill it
        if let playerView = player.view {
            // The container view is centered in the cell in the storyboard
            cell.containerView.addSubview(playerView)
            playerView.constraintToSuperview()
        }
        
        return cell
    }
    
// MARK: UICollectionViewDelegateFlowLayout implementation

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: collectionView.frame.height)
    }
    
//  MARK: UIScrollViewDelegate implementation

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems

        // Map rows as indexes
        let visibleItems = visibleIndexPaths.map({ return $0.row })

        // Check for non-visible players inside the feed
        let nonVisiblePlayers = feed.enumerated().filter { (offset: Int, player: JWPlayerController) -> Bool in
            return !visibleItems.contains(offset) && player.state == JWPlayerState.playing
        }

        // Iterate non-visible players to pause the video and remove the previous view from cell
        nonVisiblePlayers.forEach { (_, player: JWPlayerController) in
            player.pause()
            player.view?.removeFromSuperview()
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
