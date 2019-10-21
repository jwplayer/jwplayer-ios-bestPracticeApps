//
//  FeedItemCell+JWPlayerDelegate.swift
//  FeedCollectionViewController
//
//  Created by Michael Salvador on 10/21/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//
/**
 Shows the implementation of some of the JWPlayerDelegate callback methods.
 */

import UIKit

extension FeedItemCell: JWPlayerDelegate {
    
    func onReady(_ event: JWEvent & JWReadyEvent) {
        print("On ready")
        print("Setup time: \(event.setupTime)")
        if let videoTitle = player?.config.title {
            print("Video title: \(videoTitle)")
        }
    }

    func onPlay(_ event: JWEvent & JWStateChangeEvent) {
        print("On play")
        if let videoTitle = player?.config.title {
            print("Video title: \(videoTitle)")
        }
    }

    func onPause(_ event: JWEvent & JWStateChangeEvent) {
        print("On pause")
        if let videoTitle = player?.config.title {
            print("Video title: \(videoTitle)")
        }
    }

    func onFirstFrame(_ event: JWEvent & JWFirstFrameEvent) {
        print("On first frame")
        print("Load time: \(event.loadTime)")
        if let videoTitle = player?.config.title {
            print("Video title: \(videoTitle)")
        }
    }

    func onIdle(_ event: JWEvent & JWStateChangeEvent) {
        print("On idle")
        if let videoTitle = player?.config.title {
            print("Video title: \(videoTitle)")
        }
    }
    
    func onError(_ event: JWEvent & JWErrorEvent) {
        print("On error")
        if let videoTitle = player?.config.title {
            print("Video title: \(videoTitle)")
        }
    }
    
    func onAdError(_ event: JWAdEvent & JWErrorEvent) {
        print("On ad error")
        if let videoTitle = player?.config.title {
            print("Video title: \(videoTitle)")
        }
    }
}
