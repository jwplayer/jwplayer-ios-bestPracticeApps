//
//  DownloadPlayerItemOperation.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/18/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation
import JWPlayerKit

/// Constants representing errors which can occur in `DownloadPlayerItemOperation`
enum DownloadPlayerItemOperationError: Error {
    /// The video source file is invalid.
    case invalidVideoSourceFile
    /// The operation was unable to create a valid JSON file for the player item.
    case cannotCreatePlayerJSON
}

/**
 This operation takes a player item and determines what needs to be downloaded. After it
 determines this, it creates all appropriate download operations for the media, and executes them, storing
 them in a file folder named after the player item's media ID.
 */
class DownloadPlayerItemOperation: AsyncOperation {
    /// The operation queue for all download operations.
    private let opQueue = OperationQueue()
    
    /// The player item we are downloading.
    private(set) var item: JWPlayerItem!
    
    /// The directory we are storing the downloaded assets to.
    private let storageDirectory: URL
    
    /// This is used to map URLs to the downloaded local URLs.
    private var remappedURLs: [URL:URL] = [:] // [SourceURL : DestinationURL]
    
    /// This reference is held onto for reporting updates on download progress.
    private weak var videoAssetDownloadOperation: Operation?
    
    /// The tracker we report download progress to.
    internal weak var progressTracker: ProgressTracker? {
        didSet {
            if let op = videoAssetDownloadOperation as? DownloadAVAssetOperation {
                op.progressTracker = progressTracker
            }
            else if let op = videoAssetDownloadOperation as? DownloadFileOperation {
                op.progressTracker = progressTracker
            }
        }
    }
    
    /// This is set if an error occured.
    internal private(set) var error: Error?
    
    /**
     The initializer.
     - parameter item: The item to download.
     - parameter destinationDirectory: The directory we will store content in.
     */
    init(item: JWPlayerItem, to destinationDirectory: URL) {
        self.item = item
        self.storageDirectory = destinationDirectory
        
        super.init()
    }
    
    override func start() {
        super.start()
        
        DispatchQueue.global().async { [weak self] in
            do {
                try self?.beginOperation()
            }
            catch let error {
                self?.error = error
            }
            // No matter how beginOperation concludes, we end the operation.
            self?.finish()
        }
    }
    
    /**
     This method performs the bulk of the work for downloading the `JWPlayerItem`.
     Once all download operations have concluded, it will convert the `JWPlayerItem` into a `JSONObject` dictionary, and remap the URLs within it, and save it into a new file called `item.json`. By doing so, the `PlayerItemDownloadManager` can create a new player item with the remapped URLs.
     */
    private func beginOperation() throws {
        // Create a directory in the documents folder named with the media ID.
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        
        let group = DispatchGroup()
        
        // Create the download operation for the video source
        var operations: [Operation] = []
        group.enter()
        let videoSourceDownloadOperation = downloadVideoSource {
            group.leave()
        }
        
        guard let videoSourceDownloadOperation else {
            error = error ?? DownloadPlayerItemOperationError.invalidVideoSourceFile
            return
        }
        
        self.videoAssetDownloadOperation = videoSourceDownloadOperation
        operations.append(videoSourceDownloadOperation)
        
        // Create the download operation for the poster image
        group.enter()
        let posterImageDownloadOperation = downloadPosterImage {
            group.leave()
        }
        
        if let op = posterImageDownloadOperation {
            operations.append(op)
        }
        
        // Create the download operation for the captions files
        group.enter()
        let mediaTrackDownloadOperations = downloadMediaTracks {
            group.leave()
        }
        
        operations.append(contentsOf: mediaTrackDownloadOperations)
        
        // Insert the operations into the queue and await the items to complete.
        opQueue.addOperations(operations, waitUntilFinished: false)
        group.wait()
        
        // If an error ocurred, let's end this.
        guard self.error == nil else {
            return
        }
        
        // Lastly, we create a new playlist item and save it as JSON.
        group.enter()
        createJSONFile {
            group.leave()
        }
        group.wait()
    }
    
    /**
     Downloads the video file specified in the JWPlayerItem. When the download is complete the closure is called.
     - returns: This returns an operation if it is able to be created.
     */
    private func downloadVideoSource(_ downloadComplete: @escaping () -> Void) -> Operation? {
        // We get the path to the first video source. If another source is available and desired, this code should be changed to use that source.
        guard let sourceURL = item.videoSources.first?.file else {
            self.error = DownloadPlayerItemOperationError.invalidVideoSourceFile
            downloadComplete()
            return nil
        }
        
        let ext = sourceURL.pathExtension.lowercased()
        switch ext {
        case "mp4", "m4a":
            // MP4 files are treated as normal downloads.
            let destURL = storageDirectory.appendingPathComponent("videoSource.mp4")
            let op = DownloadFileOperation(source: sourceURL, destination: destURL)
            op.progressTracker = progressTracker
            op.completionBlock = { [weak self] in
                guard let self else {
                    return
                }
                self.error = (self.error == nil) ? op.error : self.error
                self.remappedURLs[sourceURL] = op.destinationURL
                downloadComplete()
            }
            return op
        case "m3u8":
            // HLS files require we use the AVAssetDownloadTask, so it needs its own operation.
            let destURL = storageDirectory.appendingPathComponent("videoSource.m3u8")
            let op = DownloadAVAssetOperation(source: sourceURL, destination: destURL, title: item.title ?? "untitled")
            op.progressTracker = progressTracker
            op.completionBlock = { [weak self] in
                guard let self else {
                    return
                }
                self.error = (self.error == nil) ? op.error : self.error
                self.remappedURLs[sourceURL] = op.destinationURL
                downloadComplete()
            }
            return op
        default:
            // If we reach here, the file is unrecognized.
            // If you need to recognize other formats, create new cases or add to
            // the existing ones above.
            self.error = DownloadPlayerItemOperationError.invalidVideoSourceFile
            downloadComplete()
        }
        
        // If we reached this point, no operation was created and an error should
        // have already been set.
        return nil
    }
    
    /**
     Downloads the poster image specified in the JWPlayerItem. When the download is complete the closure is called.
     - returns: This returns an operation if it is able to be created.
     */
    private func downloadPosterImage(_ downloadComplete: @escaping () -> Void) -> Operation? {
        guard let sourceURL = item.posterImage else {
            downloadComplete()
            return nil
        }
        
        let destURL = storageDirectory.appendingPathComponent("posterImage." + sourceURL.pathExtension)
        let op = DownloadFileOperation(source: sourceURL, destination: destURL)
        op.completionBlock = { [weak self] in
            guard let self else {
                return
            }
            self.error = (self.error == nil) ? op.error : self.error
            self.remappedURLs[sourceURL] = op.destinationURL
            downloadComplete()
        }
        return op
    }
    
    /**
     Downloads the media tracks specified in the JWPlayerItem. When the all downloads are complete the closure is called.
     - returns: This returns an array of operations if it is able to be created.
     */
    private func downloadMediaTracks(_ downloadComplete: @escaping () -> Void) -> [Operation] {
        let group = DispatchGroup()
        var operations: [Operation] = []
        var index = 0
        for track in item.mediaTracks ?? [] {
            guard let sourceURL = track.file else {
                continue
            }
            
            let destURL = storageDirectory.appendingPathComponent("mediaTrack-\(index)." + sourceURL.pathExtension)
            index += 1
            
            let op = DownloadFileOperation(source: sourceURL, destination: destURL)
            group.enter()
            op.completionBlock = { [weak self] in
                guard let self else {
                    return
                }
                self.error = (self.error == nil) ? op.error : self.error
                self.remappedURLs[sourceURL] = destURL
                group.leave()
            }
            operations.append(op)
        }
        
        opQueue.addOperation {
            group.wait()
            downloadComplete()
        }
        return operations
    }
    
    /// Creates a JSON playlist item object, changing the appropriate values to the new local URLs.
    /// After this method completes, it calls the `complete` closure.
    private func createJSONFile(_ complete: () -> Void) {
        defer {
            complete()
        }
        
        // Do not proceed if we have errors.
        guard error == nil else {
            error = DownloadPlayerItemOperationError.cannotCreatePlayerJSON
            return
        }
        
        var json = item.toJSONObject()
        guard let sourceArray = json["sources"] as? JSONArray,
              var source = sourceArray.first as? JSONObject else {
            error = DownloadPlayerItemOperationError.cannotCreatePlayerJSON
            return
        }
        
        if let path = source["file"] as? String,
            let url = URL(string: path),
            let mappedURL = remappedURLs[url] {
            source["file"] = mappedURL.absoluteString
        }
        else {
            error = DownloadPlayerItemOperationError.cannotCreatePlayerJSON
            return
        }
        
        json["sources"] = [source] // Copy the value into our main json.
        
        // Overwrite the poster image file
        if let path = json["image"] as? String,
            let url = URL(string: path),
            let mappedURL = remappedURLs[url] {
            json["image"] = mappedURL.absoluteString
        }
        
        // Write the media tracks
        if let tracks = json["tracks"] as? JSONArray {
            var localTracks: [JSONObject] = []
            for track in tracks {
                guard let track = track as? JSONObject,
                      let sourcePath = track["file"] as? String,
                      let sourceURL = URL(string: sourcePath),
                      let localURL = remappedURLs[sourceURL] else {
                    // We do not record tracks which we cannot play offline.
                    return
                }
                
                var finalTrack = track
                finalTrack["file"] = localURL.absoluteString
                localTracks.append(finalTrack)
            }
            
            json["tracks"] = localTracks
        }
        
        // Save the JSON to a file
        do {
            let url = storageDirectory.appendingPathComponent("item.json")
            let data = try JSONSerialization.data(withJSONObject: json)
            try data.write(to: url, options: .atomic)
        }
        catch let error {
            self.error = error
        }
    }
}
