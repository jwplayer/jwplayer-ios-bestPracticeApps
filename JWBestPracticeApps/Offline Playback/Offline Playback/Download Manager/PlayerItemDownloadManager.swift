//
//  PlayerItemDownloadManager.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/18/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation
import JWPlayerKit

/// Objects wishing to track progress conform to this protocol.
protocol ProgressTracker: AnyObject {
    /// This is set to a value between 0 & 1, where 0 is no progress made and 1 is complete.
    var progress: Double { get set }
}

/// An observer used to track the download operation.
/// This class is stored by the caller, and can have properties set to observe behavior within the download.
class PlayerItemDownloadObserver {
    /// This progress tracker is updated when the content is downloading.
    weak var progressTracker: ProgressTracker? {
        didSet {
            operation.progressTracker = progressTracker
        }
    }
    /// This is called when the operation is complete.
    var onComplete = { (error: Error?) in }
    
    /// The download operation.
    fileprivate let operation: DownloadPlayerItemOperation
    
    /**
     This initializer is restricted to this file so only the PlayerItemDownloadManager can create observers.
     The completion argument is used to inform the PlayerItemDownloadManager when the operation is complete.
     */
    fileprivate init(operation: DownloadPlayerItemOperation, onCompletion: @escaping () -> Void) {
        self.operation = operation
        operation.completionBlock = { [weak self] in
            self?.onComplete(operation.error) // Tell observing class it is complete
            onCompletion() // Tell PlayerItemDownloadManager the operation is complete
        }
    }
}

/**
 This class encapsulates all actions and queries related to downloading player items.
 Through this manager you can download player items and store them on the device, as well as determine
 whether items are downloaded. All player items queried through this manager must have a valid `mediaId` in their description.
 */
class PlayerItemDownloadManager {
    /// Constants representing errors which can be thrown from the manager.
    enum PlayerItemDownloadManagerError: Error {
        /// The specified item does not exist locally on the device, so the operation cannot be completed.
        case itemDoesNotExistLocally
    }
    /// The operation queue which manages the downloads.
    private let opQueue = OperationQueue()
    /// Internal tracking of all current download operations.
    private var observers: [UUID : PlayerItemDownloadObserver] = [:]
    
    /// Constants representing the state of a player item.
    enum PlayerItemState {
        /// Item is not downloaded, and only available online.
        case online
        /// Item is currently downloading.
        case downloading
        /// Item is available locally.
        case local
    }
    
    /**
     Downloads the given player item if it has not bee downloaded already. The media ID of the player item is used to differentiate the player item from other downloaded content.
     - parameter item: The player item to download. This item must have a media ID set.
     - returns: An observation object. If the player item has been downloaded, or the item does not have a media ID, `nil` is returned.
     */
    func download(item: JWPlayerItem) -> PlayerItemDownloadObserver? {
        // Create the download operation
        guard let id = item.mediaId else {
            return nil
        }
        
        // Retrieves the desired location of the media for this item.
        let directory = FileManager.default.mediaDirectory(id: id)
        
        // Create the download operation.
        // The DownloadPlayerItemOperation assembles download operations for all assets
        // within the player item, placing them in the supplied directory.
        let op = DownloadPlayerItemOperation(item: item, to: directory)
        
        // Create the download observer and record it.
        let uuid = UUID()
        let observer = PlayerItemDownloadObserver(operation: op) { [weak self] in
            // Now that the download is complete, we remove it from the observers.
            self?.observers[uuid] = nil
            
            // If an error occured, we remove what has been downloaded, if anything.
            if let _ = op.error {
                try? self?.remove(id: id)
            }
        }
        observers[uuid] = observer
        
        // Run the download and return the observer.
        opQueue.addOperation(op)
        return observer
    }
    
    /**
     If the given media exists locally, this method will remove its downloaded assets from the device.
     - parameter mediaID: The ID of the player item to remove.
     - throws: An error if the operation fails or does not exist on disk.
     */
    func remove(id: String) throws {
        // We only remove items if they are local. If it isn't local, we inform the caller.
        guard getPlayerItemState(id: id) == .local else {
            throw PlayerItemDownloadManagerError.itemDoesNotExistLocally
        }
        
        // Use the file manager to remove the folder with all of the item's assets
        let fileManager = FileManager.default
        let directoryURL = fileManager.mediaDirectory(id: id)
        try fileManager.removeItem(at: directoryURL)
    }
    
    /**
     If a `JWPlayerItem` has been downloaded and exists on disk, a `JWPlayerItem` will be returned.
     - parameter id: The ID of the player item.
     - returns: A JWPlayerItem if it exists as downloaded content.
     */
    func getDownloadedPlayerItem(id: String) -> JWPlayerItem? {
        let fileManager = FileManager.default
        let mediaDirectory = fileManager.mediaDirectory(id: id)
        let pathToJSON = mediaDirectory.appendingPathComponent("item.json")
        
        // If the file exists, we will continue.
        guard let data = try? Data(contentsOf: pathToJSON) else {
            return nil
        }
        
        // Load the item into a JSONObject
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let json = json as? JSONObject else {
                return nil
            }
            
            // Normalize the paths within the JSON dictionary to match what is on the device.
            // This is necessary since local URLs need to be stored as relative paths, since app
            // directories can change on the device for security reasons.
            let normalizedJSON = json.normalizePaths(rootDirectory: mediaDirectory.absoluteString, designator: DownloadPlayerItemOperation.baseDirectoryToken)
            
            // Initialize the player item using the JSONObject.
            let item = JWPlayerItem.from(json: normalizedJSON)
            let jwPlayerItem = item as? JWPlayerItem
            return jwPlayerItem
        } catch {
            // Print any errors to the console.
            print("Error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    /**
     Retruns the state of a given player item.
     - parameter id: The ID of the player item.
     - returns: The state of the player item, whether it is downloaded, downloading, or only available online.
     */
    func getPlayerItemState(id: String) -> PlayerItemState {
        // If the item is retrievable, we know it is local.
        if let _ = getDownloadedPlayerItem(id: id) {
            return .local
        }
        
        // If we can find a current operation with the media id, we
        // know it is currently downloading.
        let op = observers.values.first { (observer) in
            let op = observer.operation
            let isDownloadingItem = (op.item.mediaId == id)
            return isDownloadingItem
        }
        
        if op != nil {
            return .downloading
        }
        
        // If we got this far we know the item is online.
        return .online
    }
}

// MARK: - FileManager Methods

fileprivate extension FileManager {
    /// A convenience method for assembling the URL of the unique directory named after the given media id.
    func mediaDirectory(id: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryURL = documentsDirectory.appendingPathComponent("item-\(id)")
        return directoryURL
    }
}

// MARK: - JSONObject and JSONArray

fileprivate extension JSONObject {
    /**
     This method looks for relative paths stored in the `JSONObject`, and replaces instances of `designator` with the root directory, making these paths into absolute paths.
     - parameter rootDirectory: The root directory to replace `designator` with.
     - parameter designator: The string used to represent the root directory in the relative paths.
     - returns: A new instance of this `JSONObject` with all paths converted to absolute paths.
     */
    func normalizePaths(rootDirectory: String, designator: String) -> JSONObject {
        var object: JSONObject = [:]
        
        for (key, value) in self {
            switch value {
            case let value as String:
                if value.contains(designator) {
                    let absolutePath = value.replacingOccurrences(of: designator, with: rootDirectory)
                    object[key] = absolutePath
                }
                else {
                    object[key] = value
                }
            case let item as JSONObject:
                let obj = item.normalizePaths(rootDirectory: rootDirectory, designator: designator)
                object[key] = obj
            case let array as JSONArray:
                let array = array.normalizePaths(rootDirectory: rootDirectory, designator: designator)
                object[key] = array
            default:
                object[key] = value
            }
        }
        
        return object
    }
}

fileprivate extension JSONArray {
    /**
     This method looks for relative paths stored in the `JSONArray`, and replaces instances of `designator` with the root directory, making these paths into absolute paths.
     - parameter rootDirectory: The root directory to replace `designator` with.
     - parameter designator: The string used to represent the root directory in the relative paths.
     - returns: A new instance of this `JSONArray` with all paths converted to absolute paths.
     */
    func normalizePaths(rootDirectory: String, designator: String) -> JSONArray {
        var array: JSONArray = []
        
        for item in self {
            switch item {
            case let item as String:
                if item.contains(designator) {
                    let absolutePath = item.replacingOccurrences(of: designator, with: rootDirectory)
                    array.append(absolutePath)
                }
                else {
                    array.append(item)
                }
            case let item as JSONObject:
                let object = item.normalizePaths(rootDirectory: rootDirectory, designator: designator)
                array.append(object)
            case let arr as JSONArray:
                let arr = arr.normalizePaths(rootDirectory: rootDirectory, designator: designator)
                array.append(arr)
            default:
                array.append(item)
            }
        }
        
        return array
    }
}
