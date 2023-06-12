//
//  OfflinePlayTableViewController.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/18/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation
import UIKit
import JWPlayerKit

/**
 This controller manages our table view, which displays the content the user can watch and/or download.
 */
class OfflinePlayTableViewController: UITableViewController {
    /// The download manager for managing offline content.
    let downloadManager = PlayerItemDownloadManager()
    
    /// A playlist calculated by checking what items are downloaded and which are not, and making
    /// a playlist with both local and online content.
    var playlist: [JWPlayerItem] {
        var items: [JWPlayerItem] = []
        for item in samplePlaylist {
            guard let id = item.mediaId else {
                items.append(item)
                continue
            }
            
            if let offlineItem = downloadManager.getDownloadedPlayerItem(id: id) {
                items.append(offlineItem)
            }
            else {
                items.append(item)
            }
        }
        return items
    }
    
    /// This record is for tracking downloads. This allows us to track download progress.
    private var observers: [String : PlayerItemDownloadObserver] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    
    static func storyboardInstance() -> OfflinePlayTableViewController {
        // This convenience method helps us load the storyboard.
        return UIStoryboard(name: "OfflineDownload", bundle: .main).instantiateInitialViewController() as! OfflinePlayTableViewController
    }
    
    private func download(item: JWPlayerItem, for cell: OfflinePlayTableCell, at indexPath: IndexPath) {
        guard let mediaId = item.mediaId,
            let observer = downloadManager.download(item: item) else {
            return
        }
        observer.progressTracker = cell
        observer.onComplete = { [weak self] (error) in
            if let error {
                // If an error occurs, print it to the console.
                print("\(error.localizedDescription)")
            }
            // Reload the cell once downloading completes.
            // This will update the look of the cell.
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            
            // Remove the observer.
            self?.observers[mediaId] = nil
        }
        
        // Add the observer to our record and reload the cell
        // so we can see download progress.
        observers[mediaId] = observer
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - UITableViewDelegate / UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = playlist[indexPath.row]
        let mediaID = item.mediaId ?? ""
        let state = downloadManager.getPlayerItemState(id: mediaID)
        
        // Create and initialize the cell based on the state of the content.
        switch state {
        case .online:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-Online", for: indexPath)
            if let cell = cell as? OfflinePlayTableCell {
                cell.item = item
                cell.onDownloadTapped = { [weak self] in
                    // When download is tapped, we download the content onto the device.
                    self?.download(item: item, for: cell, at: indexPath)
                }
            }
            return cell
        case .downloading:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-Downloading", for: indexPath)
            if let cell = cell as? OfflinePlayTableCell {
                cell.item = item
                // We inform the download observer about the cell being
                // a progress tracker. Doing so updates the progress automatically.
                observers[mediaID]?.progressTracker = cell
            }
            return cell
        case .local:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell-Local", for: indexPath)
            if let cell = cell as? OfflinePlayTableCell {
                cell.item = item
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If the user selected the cell, and not a button within it, we
        // transition to watching the video. "play-video" is the name of the seque
        // in the storyboard.
        let item = playlist[indexPath.row]
        performSegue(withIdentifier: "play-video", sender: item)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = playlist[indexPath.row]
        let mediaID = item.mediaId ?? ""
        let status = downloadManager.getPlayerItemState(id: mediaID)
        
        // If it's not downloaded, we don't allow deletion of the data
        // since there is no data to delete.
        guard status == .local else {
            return false
        }
        
        // We are only allowing the deletion of items which are local.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // For the sake of this demo, "delete" means to delete it off of
            // the device, and not to remove it from the playlist.
            let item = playlist[indexPath.row]
            guard let mediaID = item.mediaId else {
                return
            }
            
            // Remove the content from the device.
            do {
                try downloadManager.remove(id: mediaID)
            }
            catch {
                // If we fail to remove the media, output an error to the console.
                print("\(error)")
            }
            
            // Update the table view by deleting the row
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// If the upcoming view controller is a request to watch the video, we initialize the video loader controller.
        guard let sender = sender as? JWPlayerItem,
              let vc = segue.destination as? OfflinePlayLoaderViewController else {
            return
        }
        
        vc.item = sender
    }
}
