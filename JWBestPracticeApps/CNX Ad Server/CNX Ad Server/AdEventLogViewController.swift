//
//  AdEventLogViewController.swift
//  CNX Ad Server
//

import UIKit
import JWPlayerKit

/**
 A `JWPlayerViewController` that reports every ad lifecycle event, plus every player and ad error and
 warning, through `onLog`, so the screen embedding it can show a live event log.
 */
class AdEventLogViewController: JWPlayerViewController {
    /// Called on the main queue with one line per event.
    var onLog: ((String) -> Void)?

    /// Called on the main queue when a player setup finishes, successfully or not. Call
    /// `configurePlayer(with:)` again only after this, because a configuration supplied while the
    /// previous one is still loading is rejected.
    var onSetupFinished: (() -> Void)?

    private func onMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }

    private func log(_ line: String) {
        print("[CNX BPA] \(line)")
        onMain { [weak self] in self?.onLog?(line) }
    }

    // MARK: - Setup

    override func jwplayerIsReady(_ player: JWPlayer) {
        super.jwplayerIsReady(player)
        log("Player ready")
        onMain { [weak self] in self?.onSetupFinished?() }
    }

    // This configuration failed to set up. If it was rejected because a previous one was still loading,
    // that previous one carries on.
    override func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        super.jwplayer(player, failedWithSetupError: code, message: message)
        log("setupError \(code): \(message)")
        onMain { [weak self] in self?.onSetupFinished?() }
    }

    // MARK: - Player errors and warnings

    // Player warnings include problems setting up advertising — for example a license key that is not
    // enabled for ads. Content still plays, but no ads will, so check here first if you see no ad events.
    override func jwplayer(_ player: JWPlayer, encounteredWarning code: UInt, message: String) {
        super.jwplayer(player, encounteredWarning: code, message: message)
        log("warning \(code): \(message)")
    }

    override func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        super.jwplayer(player, failedWithError: code, message: message)
        log("error \(code): \(message)")
    }

    // MARK: - Ad lifecycle

    override func jwplayer(_ player: JWPlayer, adEvent event: JWAdEvent) {
        super.jwplayer(player, adEvent: event)
        log(Self.name(of: event.type))
    }

    // Ad progress arrives many times per second through `onAdTimeEvent(_:)`. It is not overridden here;
    // override it only if you need ad progress.

    // Ad warnings report something that did not stop playback. For example, 70013 reports an ad break
    // that was skipped because a cast session is active.
    override func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        super.jwplayer(player, encounteredAdWarning: code, message: message)
        log("adWarning \(code): \(message)")
    }

    // Ad errors end the ad or break, but content playback continues. The code says why — for
    // example 10064 is usually a no-fill, and 40100 means the ad service failed to set up, so no ad
    // breaks play until the player is set up again.
    override func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        super.jwplayer(player, encounteredAdError: code, message: message)
        log("adError \(code): \(message)")
    }

    static func name(of type: JWAdEventType) -> String {
        switch type {
        case .adBreakStart: return "adBreakStart"
        case .adBreakEnd: return "adBreakEnd"
        case .schedule: return "adSchedule"
        case .request: return "adRequest"
        case .loaded: return "adLoaded"
        case .loadedXML: return "adLoadedXML"
        case .started: return "adStarted"
        case .impression: return "adImpression"
        case .viewableImpression: return "adViewableImpression"
        case .meta: return "adMeta"
        case .play: return "adPlay"
        case .pause: return "adPause"
        case .clicked: return "adClick"
        case .skipped: return "adSkipped"
        case .complete: return "adComplete"
        case .companion: return "adCompanion"
        @unknown default: return "adEvent(\(type.rawValue))"
        }
    }
}
