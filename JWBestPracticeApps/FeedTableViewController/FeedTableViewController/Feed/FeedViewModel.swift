//
//  FeedViewModel.swift
//  FeedTableViewControllerV4
//
//  Created by Amitai Blickstein on 5/2/22.
//

import Foundation
import JWPlayerKit

protocol FeedViewModelDelegate: AnyObject {
    /// Tells the delegate that new items were added to the view model, so that it can efficiently
    /// reload only the newly required UI.
    /// - Parameter newIndicesToReload: This consists of all indices for the new items.
    func didAddNewItemsToViewModel(with newIndicesToReload: [Int]?)
}

/// All hard-coded and dynamic values required by the table view.
final class FeedViewModel {
    /// Used to safely let the UI know which and when to reload only the newly added models.
    weak var delegate: FeedViewModelDelegate?
    
    init(withItems items: [JWPlayerItem], delegate: FeedViewModelDelegate? = nil) {
        self.items    = items
        self.delegate = delegate
    }
    
    
    // MARK: Private
    
    /// The source for the datasource.
    /// - note: The video feed gets 'fed' to (added) here for 'consumption' by (insertion to) the table view.
    private var items = [JWPlayerItem]()
    
    
    // MARK: Public
    
    /// The number of `JWPlayerItem`s currently in the feed/model.
    var count: Int { items.count }

    // Constant values
    let cellReuseIdentifier = PlayerItemCell.reuseIdentifier
    let cellNibName         = PlayerItemCell.reuseIdentifier
    
    /// Returns a `JWPlayerItem` representing the video model (title and URL source) in the data source.
    func itemForVideoMetadata(at index: Int) -> JWPlayerItem {
        // The (relatively simple) implementation is hidden from the table view consuming it.
        items[index]
    }
    
    /// Adds items to the view model, and thus, to the data source.
    ///
    /// Can be called repeatedly to add another copy of the playlist to the feed.
    /// - note: Call when or just before the table view reaches the end of the table in order to
    /// implement an "infinite scrolling feed".
    func appendItems(fromPlaylist newlyAppendedItems: [JWPlayerItem] ) {
        items += newlyAppendedItems
        
        let indiciesToReload = newIndicies(from: newlyAppendedItems)
        delegate?.didAddNewItemsToViewModel(with: indiciesToReload)
    }
    
    private func newIndicies(from newItems: [JWPlayerItem]) -> [Int] {
        let startIndex = items.count - newItems.count
        let endIndex   = startIndex  + newItems.count
        let newIndexes = Array(startIndex..<endIndex)
        return newIndexes
    }
}
