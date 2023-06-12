//
//  ImageLoader.swift
//  JWPlayerKitDemoApp
//
//  Created by Stephen Seibert on 5/18/23.
//  Copyright © 2023 JW Player. All rights reserved.
//

import Foundation
import UIKit

/// Constants representing errors which can occur in the ImageLoader.
enum ImageLoaderError {
    /// The image file data is corrupted or unrecognizable.
    case corruptImageFile
}

/**
 This helper class downloads images and caches them for quicker access after they have been downloaded.
 */
class ImageLoader {
    // In-memory cache for loaded images
    private var loadedImages = [URL : UIImage]()
    // Active image requests
    private var runningRequests = [UUID : URLSessionDataTask]()
    // Serial queue
    private var dispatchQueue = DispatchQueue(label: "com.ui.imageloader")
    
    /// A subscript can be used to retrieve cached images.
    subscript(_ url: URL) -> UIImage? {
        return loadedImages[url]
    }

    /**
     Loads the image at the supplied URL.
     
     If the image has been previously downloaded by this loader, the cached image will be sent.
     - parameter url: The URL to the desired image.
     - parameter completion: The result of the download, whether it is a UIImage or an Error.
     - returns: The UUID of the task. This can be used to cancel the download.
     */
    @discardableResult
    func loadImage(url: URL,
                   _ completion: @escaping (UIImage?, Error?) -> Void) -> UUID? {

        // If we already have the image in memory, return it
        if let image = loadedImages[url] {
            dispatchQueue.async {
                completion(image, nil)
            }
            return nil
        }

        // Create a unique identifier for the data task
        let uuid = UUID()
        let task = URLSession.shared.dataTask(with: url) { [weak self]  (data, response, error) in
            defer {
                self?.dispatchQueue.async { [weak self] in
                    self?.runningRequests.removeValue(forKey: uuid)
                }
            }

            if let data = data,
               let image = UIImage(data: data) {
                self?.dispatchQueue.async { [weak self] in
                    self?.loadedImages[url] = image
                    completion(image, nil)
                }
                return
            }
            else{
                completion(nil, error)
            }
        }
        runningRequests[uuid] = task
        task.resume()
        return uuid
    }

    /**
     Cancels the download.
     - parameter uuid: The identifier associated with the download.
     */
    func cancelLoad(uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
