//
//  CNXConfig.swift
//  CNX Ad Server
//

import Foundation

/**
 The ONLY place this app's publisher-specific values live.

 Every screen reads its license key, player ID and App Store ID from here; nothing else in the app
 hardcodes or duplicates them.

 ## Before you start

 Ads only play when your account is set up for them. None of the following can be checked from the
 app. Most of them fail the same way — the auction returns no ad, and the event log shows
 `adError 10064: No ad available`:

 1. **Your JW Player account is enabled for Ad Server.** Ask your JW Player account manager if unsure.
 2. **You have an App Player** in the JW dashboard property you will use: Players → In-app tab. It
    exists only to give you a player ID for targeting and analytics; styling and player settings come
    from the SDK, not from the dashboard.
 3. **Your Ad Server line items, creatives and targeting rules are in that same property.**
 4. **Your app includes the Google IMA SDK** (`GoogleAds-IMA-iOS-SDK`, 3.28.10 or later). JWPlayerKit
    does not require it for Ad Server, but some auctions are won by ads that only IMA can render, and
    without it those breaks fail.
 5. **Your app is registered for ad serving.** Registration is not self-service — contact JW Player
    support to register a new app or confirm an existing registration, and ask which App Store ID (or
    bundle identifier) it is registered under: that is the value `appStoreId` must hold. An app
    identity that does not match the registration makes the ad service fail to set up
    (`adError 40100: Ad setup failed`), and no ad breaks play.

 ## Fill in the values below

 The three required values are Xcode placeholders, so the app will not compile until you replace them.
 If a value is present but malformed, the app refuses to set up a player and shows a full-screen error
 naming the field, where to fix it, and where the value comes from.
 */
enum CNXConfig {

    // MARK: - Required

    /// Your JW Player license key for the iOS SDK.
    ///
    /// Where to find it: JW dashboard → the property from step 2 → API Credentials →
    /// JW Player License Keys. It must come from the SAME property as `dashboardPlayerId`.
    static let licenseKey: String = <#"YOUR_LICENSE_KEY"#>

    /// The ID of your App Player (8 letters and digits, e.g. "a1B2c3D4").
    ///
    /// Where to find it: JW dashboard → [your property] → Players → In-app tab → [your App Player].
    /// Together with the license key, this is the ad-server identity the SDK sends: the license key
    /// identifies the account, and the player ID scopes ad requests to this placement.
    static let dashboardPlayerId: String = <#"YOUR_APP_PLAYER_ID"#>

    /// The numeric App Store ID your app is registered under for ad serving (the "Apple ID" of the
    /// app, digits only, e.g. "886445756").
    ///
    /// Where to find it: App Store Connect → [your app] → App Information → Apple ID. It is also the
    /// number after `id` in your App Store URL. It must be the ID in your ad-serving registration.
    ///
    /// This is the app identity the ad service checks, so it decides whether ads play at all. Ad demand
    /// also targets on it, and SKAdNetwork attribution requires it.
    ///
    /// Only if your app is registered by its bundle identifier instead (for example, it has no App
    /// Store ID yet): set this to "". The SDK then sends this build's bundle identifier, so the
    /// target's Bundle Identifier (Signing & Capabilities) must be exactly the registered one.
    static let appStoreId: String = <#"YOUR_APP_STORE_ID"#>

    /// `appStoreId` with surrounding whitespace removed, or `nil` when it is empty. This is what is
    /// sent to the ad service.
    static var appStoreIdValue: String? {
        let trimmed = appStoreId.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - Validation

    /// One reason the configuration is not ready to serve ads.
    struct Problem {
        /// The `CNXConfig` field that is wrong.
        let field: String
        /// What is wrong, what to set, and where the value comes from.
        let detail: String
    }

    /// Returns every problem with the values above. An empty array means the app may set up players.
    static func validate() -> [Problem] {
        var problems: [Problem] = []

        if isBlank(licenseKey) || licenseKey == "YOUR_LICENSE_KEY" {
            problems.append(Problem(
                field: "licenseKey",
                detail: "Not set. Set it in CNXConfig.swift to your JW Player license key — JW dashboard → "
                    + "[your property] → API Credentials → JW Player License Keys."))
        }

        if !isPlayerId(dashboardPlayerId) {
            problems.append(Problem(
                field: "dashboardPlayerId",
                detail: "\"\(dashboardPlayerId)\" is not a player ID. It must be exactly 8 letters and digits, "
                    + "copied from JW dashboard → [your property] → Players → In-app tab → [your App Player]."))
        }

        if let appStoreId = appStoreIdValue, !appStoreId.allSatisfy({ $0.isASCII && $0.isNumber }) {
            problems.append(Problem(
                field: "appStoreId",
                detail: "\"\(appStoreId)\" is not an App Store ID. Use the numeric Apple ID your app is registered "
                    + "under (e.g. \"886445756\"), not the bundle identifier or the full App Store URL. Only if your "
                    + "app is registered for ad serving by its bundle identifier, set it to \"\" instead."))
        }

        return problems
    }

    /// Advice that does not stop the app from running.
    static func warnings(bundleIdentifier: String? = Bundle.main.bundleIdentifier) -> [String] {
        appStoreIdValue == nil
            ? ["CNXConfig.appStoreId is empty, so the SDK sends this build's bundle identifier "
               + "(\"\(bundleIdentifier ?? "none")\") as the app identity. If that is not the identity your app "
               + "is registered under, the ad service fails to set up (adError 40100) and no ads play."]
            : []
    }

    private static func isBlank(_ value: String) -> Bool {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private static func isPlayerId(_ value: String) -> Bool {
        value.count == 8 && value.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber) }
    }
}
