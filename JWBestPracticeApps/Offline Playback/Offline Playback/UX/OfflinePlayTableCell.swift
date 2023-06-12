//
//  OfflinePlayTableCell.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/18/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation
import UIKit
import JWPlayerKit

/**
 This class represents a table cell with information about JWPlayerItems available to watch or download.
 For simplicity in this demo, this cell handles all three states of the content, as defined by the `PlayerItemDownloadManager`.
 */
class OfflinePlayTableCell: UITableViewCell, ProgressTracker {
    /// If this view exists, it will display the poster image from the item.
    @IBOutlet var thumbnailView: UIImageView?
    /// If this view exists, it will display the download progress of the item.
    @IBOutlet var progressView: ProgressView?
    /// If this view exists, it will display the title of the item.
    @IBOutlet var titleLabel: UILabel?
    
    // A shared image loader between table cells.
    private static let imageLoader = ImageLoader()
    
    /// When set, the cell will update itself to reflect the item.
    var item: JWPlayerItem? {
        didSet {
            titleLabel?.text = item?.title
            updateThumbnail()
        }
    }
    
    /// This closure is called when the download button is tapped.
    var onDownloadTapped = {}
    
    /// This progress value (0 - 1) will be reflected in the progress bar, if one exists.
    var progress: Double = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                self.progressView?.progress = self.progress
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        progress = 0
        titleLabel?.text = nil
        thumbnailView?.image = nil
    }
    
    private func updateThumbnail() {
        // Download the image if needed.
        thumbnailView?.image = nil
        if let imageUrl = item?.posterImage {
            // Check if the image is cached, and use it if it is.
            if let image = OfflinePlayTableCell.imageLoader[imageUrl] {
                thumbnailView?.image = image
            }
            else {
                // If the image was not cached, download it and display it.
                OfflinePlayTableCell.imageLoader.loadImage(url: imageUrl) { [weak self] (image, error) in
                    guard error == nil else {
                        print("Cell Image Download Error: \(error!)")
                        return
                    }
                    
                    // Update the thumbnail view.
                    DispatchQueue.main.async { [weak self] in
                        self?.thumbnailView?.image = image
                    }
                }
            }
        }
    }
    
    /// This method is called when the user taps the download button.
    @IBAction private func downloadItem(_ button: UIButton) {
        onDownloadTapped()
    }
}
