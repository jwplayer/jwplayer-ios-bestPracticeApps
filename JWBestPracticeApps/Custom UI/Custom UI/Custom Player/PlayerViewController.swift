//
//  PlayerViewController.swift
//  Custom UI
//
//  Created by Stephen Seibert on 2/8/22.
//

import Foundation
import JWPlayerKit

/**
 The PlayerViewController contains the JWPlayerView, and handles the events and changing of the interfaces.
 */
class PlayerViewController: ViewController {
    
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
        DispatchQueue.main.async { [weak viewManager] in
            switch event.type {
            case .adBreakStart:
                viewManager?.interface = .ads
            case .adBreakEnd:
                viewManager?.interface = .video
            case .pause:
                viewManager?.state = .paused
            case .play:
                viewManager?.state = .playing
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
            print("maximize tapped")
        case .minimizeWindow:
            print("minimize tapped")
        case .skipAd:
            player.skipAd()
        case .learnMore:
            print("learn more tapped")
        }
    }
}
