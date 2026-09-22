//
//  CNXPlayerConfiguration.swift
//  CNX Ad Server
//

import Foundation
import JWPlayerKit

/// How ad breaks are placed in the content.
enum AdScheduling {
    /// An explicit schedule: a pre-roll, a mid-roll at 30 seconds, and a post-roll. The ad server
    /// auctions each break; no VAST tags are needed.
    case manual
    /// You list which positions may have a break (pre, mid, post) and give timing rules; the SDK's ad
    /// scheduler places the mid-rolls by those rules, and the ad server auctions each break.
    case dynamic
}

/**
 Builds every player configuration in this app, so the CNX setup is written once.

 All publisher-specific values come from `CNXConfig`. The ad-server identity is the license key, the
 App Player ID and the App Store ID together; all three must match your account and registration.
 */
enum CNXPlayerConfiguration {
    private static let contentURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!

    /// Content seconds before the first dynamic mid-roll, and between later ones.
    static let dynamicFirstMidrollAfter: TimeInterval = 30
    static let dynamicSecondsBetweenMidrolls: TimeInterval = 60

    /**
     - parameter scheduling: How ad breaks are placed.
     - parameter autoPauseAdsOnViewability: Whether a playing ad pauses while the player is scrolled
       out of view, and resumes when it comes back.
     */
    static func make(scheduling: AdScheduling,
                     autoPauseAdsOnViewability: Bool = false,
                     autostart: Bool = true) throws -> JWPlayerConfiguration {
        let item = try JWPlayerItemBuilder()
            .file(contentURL)
            .title("CNX Ad Server")
            .build()

        let settings = JWCNXSettingsBuilder()
            // "strict" (the default) holds new auctions while the player is out of view. It never
            // pauses an ad that is already playing — that is what autoPauseAdsOnViewability does.
            .viewabilityPolicy("strict")
            .autoPauseAdsOnViewability(autoPauseAdsOnViewability)
            // Turns on the Google IMA SDK's own debug logging for IMA-rendered ads, and marks ad
            // requests as debug requests. Remove before shipping.
            .debugMode(true)

        // The App Store ID your app is registered under for ad serving. It is the app identity the ad
        // service checks: without it the SDK sends the bundle identifier instead, and unless your app is
        // registered by that bundle identifier the ad service fails to set up (adError 40100).
        if let appStoreId = CNXConfig.appStoreIdValue {
            settings.appStoreId(appStoreId)
        }

        let advertising = JWCNXAdvertisingConfigBuilder()

        switch scheduling {
        case .manual:
            advertising.schedule([
                try JWCNXAdBreakBuilder().offset(.preroll()).build(),
                try JWCNXAdBreakBuilder().offset(.midroll(seconds: 30)).build(),
                try JWCNXAdBreakBuilder().offset(.postroll()).build()
            ])
        case .dynamic:
            let rules = JWCNXDynamicAdRulesBuilder()
                .forcePreroll(true)
                .secondsOfContentBeforeFirstAd(dynamicFirstMidrollAfter)
                .secondsOfContentBetweenAds(dynamicSecondsBetweenMidrolls)
                .build()
            // Only the positions listed here can ever play; the rules above only decide WHEN. A break
            // with no tag or VAST XML is auctioned by the ad server.
            let auctionedBreak = JWCNXDynamicAdBreakBuilder().build()
            settings.dynamicAds(JWCNXDynamicAdsConfigBuilder()
                .rules(rules)
                .adBreak("pre", auctionedBreak)
                .adBreak("mid", auctionedBreak)
                .adBreak("post", auctionedBreak)
                .build())
        }

        advertising.cnxSettings(settings.build())

        return try JWPlayerConfigurationBuilder()
            .playlist(items: [item])
            // Your App Player's ID, which scopes ad requests to this placement.
            .playerId(CNXConfig.dashboardPlayerId)
            .advertising(try advertising.build())
            .autostart(autostart)
            .build()
    }
}
