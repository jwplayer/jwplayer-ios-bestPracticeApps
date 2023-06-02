//
//  DownloadAVAssetOperation.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/18/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation
import AVFoundation

/// Constants representing the errors which can occur in `DownloadAVAssetOperation`
enum DownloadAVAssetOperationError: Error {
    /// The download task is unable to be created.
    case unableToCreateDownloadTask
}

/**
 An operation used to download HLS AVAssets.
 */
class DownloadAVAssetOperation: AsyncOperation, AVAssetDownloadDelegate {
    private var downloadSession: AVAssetDownloadURLSession!
    private var assetDownloadTask: AVAssetDownloadTask!
    
    /// The URL of the item to be downloaded.
    internal let sourceURL: URL
    /// The destination to copy the downloaded item to.
    internal let destinationURL: URL
    /// The human-readable title of the asset.
    internal let title: String
    
    /// This is set if an error occured.
    internal private(set) var error: Error?
    
    /// This progress tracker is updated as the download progresses.
    internal weak var progressTracker: ProgressTracker? {
        didSet {
            progressTracker?.progress = progress
        }
    }
    
    private var progress: Double = 0 {
        didSet {
            progressTracker?.progress = progress
        }
    }
    
    /**
     The initializer for the operation.
     - parameter fileURL: The URL of the item to download.
     - parameter destination: The destination to copy the downloaded item to.
     */
    init(source fileURL: URL, destination: URL, title: String) {
        self.sourceURL = fileURL
        self.destinationURL = destination
        self.title = title
        super.init()
    }
    
    override func start() {
        super.start()
        
        // Configure the session
        let identifier = "\(UUID()).background"
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.allowsCellularAccess = true
        configuration.networkServiceType = .video
        downloadSession = AVAssetDownloadURLSession(configuration: configuration, assetDownloadDelegate: self, delegateQueue: .main)
        
        // Create the task
        let assetUrl = AVURLAsset(url: sourceURL)
        
        guard let task = downloadSession.makeAssetDownloadTask(asset: assetUrl, assetTitle: title, assetArtworkData: nil, options: nil) else {
            self.error = DownloadAVAssetOperationError.unableToCreateDownloadTask
            finish()
            return
        }
        
        // Start the task
        assetDownloadTask = task
        assetDownloadTask.resume()
    }
    
    // MARK: - AVAssetDownloadDelegate
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            // Move the item to the desired location after download completes.
            let fileManager = FileManager.default
            try fileManager.moveItem(at: location, to: destinationURL)
        } catch {
            self.error = error
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.error = (self.error) ?? error
        downloadSession.finishTasksAndInvalidate()
        downloadSession = nil
        finish()
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        var percentComplete = 0.0
            
        // Iterate through the loaded time ranges
        for value in loadedTimeRanges {
            // Unwrap the CMTimeRange from the NSValue
            let loadedTimeRange = value.timeRangeValue
            // Calculate the percentage of the total expected asset duration
            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        
        self.progress = percentComplete
    }
}
