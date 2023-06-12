//
//  DownloadFileOperation.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/18/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation
import UIKit

/// Constants representing the errors which can occur in `DownloadFileOperation`
enum DownloadFileOperationError: Error {
    case fileNotFound
    case fileEmpty
}

/**
 An operation used to download files.
 */
class DownloadFileOperation: AsyncOperation, URLSessionDownloadDelegate {
    // A reference to our download task.
    private var task: URLSessionDownloadTask!
    
    /// The URL of the item to be downloaded.
    internal let sourceURL: URL
    /// The destination to copy the downloaded item to.
    internal let destinationURL: URL
    
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
    init(source fileURL: URL, destination: URL) {
        self.sourceURL = fileURL
        self.destinationURL = destination
        super.init()
    }
    
    override func start() {
        super.start()
        
        // Create the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        
        // Create the download task
        self.task = session.downloadTask(with: sourceURL)
        task.resume()
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // Update the progress tracker with the current progress of the download.
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        self.progress = progress
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        defer {
            finish()
        }
        
        guard downloadTask.error == nil,
              let response = downloadTask.response else {
            self.error = downloadTask.error
            return
        }

        // Check whether the HTTP response was successful.
        if let httpResponse = response as? HTTPURLResponse, httpResponse.hasFailed() {
            self.error = DownloadFileOperationError.fileNotFound
            return
        }

        // Check that the data downloaded correctly.
        guard let data = try? Data(contentsOf: location) else {
            self.error = DownloadFileOperationError.fileNotFound
            return
        }

        guard !data.isEmpty else {
            self.error = DownloadFileOperationError.fileEmpty
            return
        }
        
        // Move the file to its new destination.
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: self.destinationURL.absoluteString) {
                try fileManager.removeItem(at: self.destinationURL)
            }
            try fileManager.moveItem(at: location, to: self.destinationURL)
        } catch let error {
            self.error = error
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.error = (self.error == nil) ? error : self.error
        finish()
    }
}

// MARK: - HTTPURLResponse Extension

/// Helpful methods for the HTTPURLResponse class.
fileprivate extension HTTPURLResponse {
    /// Returns true if the response denotes success.
    func isSuccessful() -> Bool {
        return statusCode >= 200 && statusCode <= 299
    }

    /// Returns true if the response is anything other than success.
    func hasFailed() -> Bool {
        return !isSuccessful()
    }
}
