##  CNX Ad Server - Best Practices App

The CNX Ad Server project illustrates how to set up the player with JW Player's Ad Server (CNX) for in-app advertising: identity, ad scheduling, event listening, and pausing ads when the player scrolls out of view.

> **Requires JWPlayerKit 4.30.0 or later** (the first version that supports Ad Server) and iOS 15.0 or later.

### Before you start

Ads only play when your account is set up for them. None of the following can be checked from the app. Most of them fail the same way — the auction returns no ad, and the event log shows `adError 10064: No ad available`:

1. **Your JW Player account is enabled for Ad Server.** Ask your JW Player account manager if unsure.
2. **You have an App Player** in the JW dashboard property you will use: Players → In-app tab. It exists only to give you a player ID for targeting and analytics; styling and player settings come from the SDK, not from the dashboard.
3. **Your Ad Server line items, creatives and targeting rules are in that same property.**
4. **Your app includes the Google IMA SDK** (`GoogleAds-IMA-iOS-SDK`, 3.28.10 or later). JWPlayerKit does not require it for Ad Server, but some auctions are won by ads that only IMA can render, and without it those breaks fail. This app's Podfile already adds it.
5. **Your app is registered for ad serving.** Registration is not self-service — contact JW Player support to register a new app or confirm an existing registration, and ask which App Store ID (or bundle identifier) it is registered under: that is the value `appStoreId` must hold. An app identity that does not match the registration makes the ad service fail to set up (`adError 40100: Ad setup failed`), and no ad breaks play.

### Setup

1. Open `CNX Ad Server/CNXConfig.swift`. It is the **only** place publisher-specific values live; every screen reads from it.

   | Value | Required? | What it is | Where to find it |
   | --- | --- | --- | --- |
   | `licenseKey` | **Yes** | Your JW Player license key | JW dashboard → [your property] → API Credentials → JW Player License Keys |
   | `dashboardPlayerId` | **Yes** | The ID of your App Player, from the **same** property (8 letters and digits) | JW dashboard → [your property] → Players → In-app tab → [your App Player] |
   | `appStoreId` | **Yes** | The numeric App Store ID your app is registered under for ad serving. It is the app identity the ad service checks, so it decides whether ads play. Only if your app is registered by bundle identifier instead: set it to `""`, and the SDK sends the build's bundle identifier, which must then be exactly the registered one (target → Signing & Capabilities; this sample ships as `com.example.CNXAdServer`). SKAdNetwork attribution is then unavailable | Your ad-serving registration (step 5). Normally your app's Apple ID: App Store Connect → [your app] → App Information → Apple ID |

   The three required values are Xcode placeholders, so **the app does not compile until you replace them**.

2. Run the app.

If a value is present but malformed — for example a player ID that isn't 8 letters and digits — the app **refuses to set up a player** and shows a full-screen error naming the field, where to fix it, and where the value comes from. The same text is printed to the console.

### What this app shows

- **Setup and event listening** (`ViewController`, the launch screen): the simplest Ad Server setup, with a live log of every ad event, error and warning underneath the player. The player is configured in one place, `CNXPlayerConfiguration`.
- **Manual and dynamic scheduling** (the segmented control on the launch screen): **Manual** is an explicit pre-roll, mid-roll at 30 seconds and post-roll, with each break auctioned by the ad server — no VAST tags. **Dynamic** lists which positions may have a break (pre, mid, post) and gives timing rules; the SDK's ad scheduler places the mid-rolls by those rules — none before 30 seconds of content, and at least 60 seconds of content between breaks — and the ad server auctions each break. Mid- and post-rolls play only at the positions added with `adBreak(_:_:)`; the pre-roll is controlled by `forcePreroll`.
- **Pause on scroll / viewability** (`FeedViewController`, the **Feed** button): a player inside an article, set up with `autoPauseAdsOnViewability(true)`. Scroll the player out of view during an ad and the ad pauses; scroll it back and the ad resumes.

### Reading the event log

A no-fill is not a failure of the app. When an auction returns no ad you will see `adRequest` followed by `adError 10064: No ad available`, and content continues. Other codes point at specific problems. `40100` means the ad service failed to set up — check first that `appStoreId` is the identity your app is registered under. Most other account-side misconfigurations (a player ID from a different property than the license key, line items in another property) are not reported as errors: the ad server simply returns no ad, so they look like a `10064` no-fill. If you only ever see `10064`, work through *Before you start*. The log also shows player warnings, which is where an advertising setup problem such as a license key without ads appears. For all error codes, see the [iOS SDK errors reference](https://docs.jwplayer.com/players/docs/ios-sdk-errors-reference).


### For production

This app shows the minimum needed for ads to play. Before you ship your own app, also:

- Add your demand partners' SKAdNetwork IDs to your Info.plist (`SKAdNetworkItems`). The SDK sends them with ad requests for install attribution, but only when `appStoreId` is set.
- Add `NSUserTrackingUsageDescription` to your Info.plist and request App Tracking Transparency authorization before the first player loads. Without it, ad requests carry no advertising identifier.
- Remove `debugMode(true)` from your settings.
