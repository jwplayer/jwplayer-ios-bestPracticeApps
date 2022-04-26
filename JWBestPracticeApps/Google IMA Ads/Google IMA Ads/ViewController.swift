//
//  ViewController.swift
//  Google IMA Ads
//
//  Created by David Almaguer on 09/08/21.
//

import UIKit
import JWPlayerKit

class ViewController: JWPlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the player.
        setupPlayerWithAdsInPlayerItems()
    }

    lazy var videoUrl  = URL(string:videoUrlString)!
    lazy var videoUrl2 = URL(string:videoUrlString2)!
    lazy var posterUrl = URL(string:posterUrlString)!
    
    private func setupPlayerWithAdsInPlayerItems() {
        do {
            // ad breaks
            // IMA Sample Ad, Single Skippable Linear
            let adBreakIMA_SSL = try! JWAdBreakBuilder()
                .offset(.preroll())
                .tags([IMA_SSL])
                .build()
            
            // IMA Sample Ad, Single Inline Linear
            let adBreakIMA_SIL = try! JWAdBreakBuilder()
                .offset(.preroll())
                .tags([IMA_SIL])
                .build()
            
            // player items
            // Big Buck Bunny
            let playerItem = try JWPlayerItemBuilder()
                .file(videoUrl)
                .posterImage(posterUrl)
                .adSchedule(breaks: [adBreakIMA_SSL])
                .build()
            
            // Sintel trailer
            let playerItem2 = try JWPlayerItemBuilder()
                .file(videoUrl2)
                .posterImage(posterUrl)
                .adSchedule(breaks: [adBreakIMA_SIL])
                .build()
            
            // IMA ad config
            let imaAdConfig = try JWImaAdvertisingConfigBuilder()
                .build()
            
            // Third, create a player config with the created JWPlayerItem and JWAdvertisingConfig.
            let config = try JWPlayerConfigurationBuilder()
                .playlist([playerItem, playerItem2])
                .advertising(imaAdConfig)
                .autostart(true)
                .build()

            // Lastly, use the created JWPlayerConfiguration to set up the player.
            player.configurePlayer(with: config)
        } catch {
            // Builders can throw, so be sure to handle build failures.
            print("*** ERROR: \(error.localizedDescription)")
            return
        }
    }

    //pragma MARK: - Related advertising methods

    // Reports when an event is emitted by the player.
    override func jwplayer(_ player: AnyObject, adEvent event: JWAdEvent) {
        super.jwplayer(player, adEvent: event)

        switch event.type {
        case .adBreakStart:
            print("The ad break has begun")
        case .request:
            print("The ad(s) has been requested")
        case .started:
            print("The ad playback has started")
        case .impression:
            print("The ad impression has been fulfilled")
        case .clicked:
            print("The ad has been tapped")
        case .pause:
            print("The ad playback has been paused")
        case .play:
            print("The ad playback has been resumed")
        case .skipped:
            print("The ad has been skipped")
        case .complete:
            print("The ad playback has finished")
        case .adBreakEnd:
            print("The ad break has finished")
        default:
            break
        }
    }

    // This method is triggered when a time event fires for a currently playing ad.
    override func onAdTimeEvent(_ time: JWTimeData) {
        super.onAdTimeEvent(time)

        // If you are not interested in the ad time data, avoid overriding this method due to performance reasons.
    }

    // When the player encounters an ad warning within the SDK, this method is called on the delegate.
    // Ad warnings do not prevent the ad from continuing to play.
    override func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        super.jwplayer(player, encounteredAdWarning: code, message: message)

        print("An ad warning has been encountered: (\(code))-\(message)")
    }

    // When the player encounters an ad error within the SDK, this method is called on the delegate.
    // Ad errors prevent ads from playing, but do not prevent media playback from continuing.
    override func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        super.jwplayer(player, encounteredAdError: code, message: message)

        print("An ad error has been encountered: (\(code))-\(message)")
    }

    
    fileprivate let videoUrlString  = "https://cdn.jwplayer.com/videos/CXz339Xh-sJF8m8CA.mp4"
    fileprivate let videoUrlString2 = "http://content.bitsontherun.com/videos/3XnJSIm4-injeKYZS.mp4"
    fileprivate let posterUrlString = "https://cdn.jwplayer.com/thumbs/CXz339Xh-720.jpg"
    
    fileprivate let IMA_SSL = URL(string: "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=")!
    
    fileprivate let IMA_SIL = URL(string: "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=")!
}
