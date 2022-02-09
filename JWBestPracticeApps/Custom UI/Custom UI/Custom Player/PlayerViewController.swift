//
//  PlayerViewController.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import JWPlayerKit
import UIKit

/**
 The PlayerViewController contains the JWPlayerView, and handles the events and changing of the interfaces.
 */
class PlayerViewController: ViewController {
    fileprivate var adClickThroughUrl: URL?
    
    private var fullScreenViewController: FullScreenPlayerViewController?
    
    // MARK: - Public Methods and Properties
    
    var config: JWPlayerConfiguration? {
        didSet {
            // Load the config, and if necessary, trigger viewDidLoad.
            // If viewDidLoad is not triggered, then playerView is nil.
            guard let config = self.config, view != nil else {
                return
            }
            
            playerView.player.configurePlayer(with: config)
        }
    }
    
    // MARK: - Player View Handling
    
    fileprivate var viewManager = PlayerViewManager()
    
    private var playerView: JWPlayerView {
        return viewManager.playerView
    }
    
    fileprivate var player: JWPlayer {
        return playerView.player
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        viewManager.setController(self)
        viewManager.buttonListener = self
        
        // Setup the player
        player.delegate = self
        player.playbackStateDelegate = self
        player.adDelegate = self
        
        // Setup the time observer
        player.mediaTimeObserver = { [weak viewManager] (time) in
            DispatchQueue.main.async { [weak viewManager] in
                viewManager?.currentTime = time
            }
        }
    }
    
    /// When called, the video will be presented across the entire screen, in landscape.
    func goFullScreen() {
        // Create the full screen view controller.
        fullScreenViewController = FullScreenPlayerViewController()
        fullScreenViewController!.modalPresentationStyle = .fullScreen
        
        // Assign the full screen view controller as the new controller
        // so the video is put into its view hierarchy, and present it.
        viewManager.setController(fullScreenViewController!)
        present(fullScreenViewController!, animated: true)
    }
    
    // When called, the video returns to normal non-full screen size.
    func exitFullScreen() {
        viewManager.setController(self)
        fullScreenViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - JWPlayerDelegate

extension PlayerViewController: JWPlayerDelegate {
    
    func jwplayerIsReady(_ player: JWPlayer) {
        player.play()
    }
    
    func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        print("JWPlayer Error (\(code)): \(message)")
    }
    
    func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        print("JWPlayer Setup Error (\(code)): \(message)")
    }
    
    func jwplayer(_ player: JWPlayer, encounteredWarning code: UInt, message: String) {
        print("JWPlayer Warning (\(code)): \(message)")
    }
    
    func jwplayer(_ player: JWPlayer, encounteredAdWarning code: UInt, message: String) {
        print("JWPlayer Ad Warning (\(code)): \(message)")
    }
    
    func jwplayer(_ player: JWPlayer, encounteredAdError code: UInt, message: String) {
        print("JWPlayer Ad Error (\(code)): \(message)")
    }
}

extension PlayerViewController: JWPlayerStateDelegate {
    func jwplayerContentWillComplete(_ player: JWPlayer) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, willPlayWithReason reason: JWPlayReason) {
        // Unimplemented in this example.
    }
    
    func jwplayerContentIsBuffering(_ player: JWPlayer) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, updatedBuffer percent: Double, position time: JWTimeData) {
        // Unimplemented in this example.
    }
    
    func jwplayerContentDidComplete(_ player: JWPlayer) {
        DispatchQueue.main.async { [weak viewManager] in
            viewManager?.interface = .none
        }
    }
    
    func jwplayer(_ player: JWPlayer, didFinishLoadingWithTime loadTime: TimeInterval) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, isPlayingWithReason reason: JWPlayReason) {
        DispatchQueue.main.async { [weak viewManager] in
            viewManager?.state = .playing
        }
    }
    
    func jwplayer(_ player: JWPlayer, isAttemptingToPlay playlistItem: JWPlayerItem, reason: JWPlayReason) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, didPauseWithReason reason: JWPauseReason) {
        DispatchQueue.main.async { [weak viewManager] in
            viewManager?.state = .paused
        }
    }
    
    func jwplayer(_ player: JWPlayer, didBecomeIdleWithReason reason: JWIdleReason) {
        DispatchQueue.main.async { [weak viewManager] in
            viewManager?.interface = .video
            viewManager?.state = .idle
        }
    }
    
    func jwplayer(_ player: JWPlayer, isVisible: Bool) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, didLoadPlaylist playlist: [JWPlayerItem]) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, didLoadPlaylistItem item: JWPlayerItem, at index: UInt) {
        // Unimplemented in this example.
    }
    
    func jwplayerPlaylistHasCompleted(_ player: JWPlayer) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, usesMediaType type: JWMediaType) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, seekedFrom oldPosition: TimeInterval, to newPosition: TimeInterval) {
        // Unimplemented in this example.
    }
    
    func jwplayerHasSeeked(_ player: JWPlayer) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, playbackRateChangedTo rate: Double, at time: TimeInterval) {
        // Unimplemented in this example.
    }
}

extension PlayerViewController: JWAdDelegate {
    func jwplayer(_ player: AnyObject, adEvent event: JWAdEvent) {
        DispatchQueue.main.async { [weak viewManager, weak self] in
            switch event.type {
            case .adBreakStart:
                viewManager?.interface = .ads
            case .adBreakEnd:
                viewManager?.interface = .video
            case .pause:
                viewManager?.state = .paused
            case .play:
                viewManager?.state = .playing
            case .impression:
                let impression = event[.impression] as? JWAdImpression
                self?.adClickThroughUrl = impression?.clickThroughURL
            default:
                break
            }
        }
    }
}

extension PlayerViewController: InterfaceButtonListener {
    func interfaceButtonTapped(_ button: InterfaceButton) {
        switch button {
        case .play:
            player.play()
        case .pause:
            player.pause()
        case .maximizeWindow:
            viewManager.windowState = .fullscreen
            goFullScreen()
        case .minimizeWindow:
            viewManager.windowState = .normal
            exitFullScreen()
        case .skipAd:
            player.skipAd()
        case .learnMore:
            guard let url = adClickThroughUrl, UIApplication.shared.canOpenURL(url) else {
                return
            }
            
            UIApplication.shared.open(url)
        }
    }
}
