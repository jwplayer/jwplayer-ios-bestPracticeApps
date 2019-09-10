//
//  FeedTableViewController.swift
//  FeedTableViewController
//
//  Created by David Almaguer on 8/14/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {
    
    var feed = [JWPlayerController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the custom cell view
        self.tableView.register(UINib.init(nibName: FeedItemCellIdentifier, bundle: Bundle.main), forCellReuseIdentifier: FeedItemCellIdentifier)
        
        fetchFeed()
    }
    
    fileprivate func fetchFeed() {
        guard let feedFilePath = Bundle.main.path(forResource: "Feed", ofType: "plist"),
            let feedInfo = NSArray.init(contentsOfFile: feedFilePath) as? [Dictionary<String, String>] else {
            return
        }
        
        // Populate the feed array with video players
        for itemInfo in feedInfo {
            guard let url = itemInfo["url"] else {
                continue
            }
            
            let config = JWConfig.init(contentUrl: url)
            
            if let player = JWPlayerController.init(config: config) {
                config.title = itemInfo["title"]
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
        
        // Get player from the feed array
        let player = feed[indexPath.row]
        
        // Add player view to the container view of the cell
        if let playerView = player.view {
            cell.containerView.addSubview(playerView)
            playerView.constraintToSuperview()
        }
        
        return cell
    }

//  MARK: UISCrollViewDelegate implementation
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }

        // Map rows as indexes
        let visibleRows = visibleIndexPaths.map({ return $0.row })
        // Check for non-visible players inside the feed
        let nonVisiblePlayers = feed.enumerated().filter { (offset: Int, player: JWPlayerController) -> Bool in
            return !visibleRows.contains(offset) && player.state == JWPlayerState.playing
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
