//
//  ViewController.swift
//  Google DAI Ads
//
//  Created by David Almaguer on 10/08/21.
//

import UIKit
import JWPlayerKit

class ViewController: JWPlayerViewController {
    private let videoID = "tears-of-steel"
    private let cmsID = "2548831"
    private let assetKey = "sN_IYUG8STe1ZzhIIE_ksA"
    private let fallbackVideoUrlString = "https://cdn.jwplayer.com/videos/CXz339Xh-sJF8m8CA.mp4"
    private let posterUrlString = "https://cdn.jwplayer.com/thumbs/CXz339Xh-720.jpg"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the player.
        setUpPlayer()
    }

    /**
     Sets up the player with an advertising configuration.
     */
    private func setUpPlayer() {
        let videoUrl = URL(string:fallbackVideoUrlString)!
        let posterUrl = URL(string:posterUrlString)!

        // Open a do-catch block to handle possible errors with the builders.
        do {
            // First, use the JWPlayerItemBuilder to create a JWPlayerItem that will be used by the player configuration.
            // This player item will be used as a fallback video in the case the DAI stream cannot be loaded.
            let playerItem = try JWPlayerItemBuilder()
                .file(videoUrl)
                .posterImage(posterUrl)
                .build()

            // Second, use the JWGoogleDAIStreamBuilder() to create a JWGoogleDAIStream that will be used by the advertising configuration.
            let daiStream = try JWGoogleDAIStreamBuilder()
                // For VoD streams use vodStreamInfo(videoID: cmsID:) to create the JWGoogleDAIStream
                .vodStreamInfo(videoID: videoID, cmsID: cmsID)
                // For Live streams use liveStreamInfo(assetKey:) to create the JWGoogleDAIStream
                //.liveStreamInfo(assetKey: assetKey)
                // If both are set (vod & live) the builder will throw an error.
                .build()

            // Third, use the JWImaDaiAdvertisingConfigBuilder to create a JWAdvertisingConfig that will be used by the player configuration.
            let adConfig = try JWImaDaiAdvertisingConfigBuilder()
                // Set the DAI stream for the builder to use.
                .googleDAIStream(daiStream)
                .build()

            // Fourth, create a player config with the created JWPlayerItem and JWAdvertisingConfig.
            let config = try JWPlayerConfigurationBuilder()
                .playlist(items: [playerItem])
                .advertising(adConfig)
                .autostart(true)
                .build()

            // Lastly, use the created JWPlayerConfiguration to set up the player.
            player.configurePlayer(with: config)
        } catch {
            print(error.localizedDescription)
            return
        }
    }

    //pragma MARK: - Related advertising methods

    // Reports when an event is emitted by the player.
    override func jwplayer(_ player: JWPlayer, adEvent event: JWAdEvent) {
        super.jwplayer(player, adEvent: event)

        switch event.type {
        case .adBreakStart:
            print("The ad break has begun")
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

}

