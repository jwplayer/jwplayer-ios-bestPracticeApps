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
 The PlayerViewController handles all events from user input and from the player itself.
 It leaves all management of the view hierarchy to PlayerViewManager, and informs this manager
 on the state of the player so the view manager is updated accordingly.
 */
class PlayerViewController: ViewController {
    /// When we enter full screen mode we save a reference to the view controller so we can dismiss it later.
    private var fullScreenViewController: FullScreenPlayerViewController?
    
    // MARK: - Public Methods and Properties
    
    /// This is the config to load in the player. When set it will initialize the view hierarchy if it isn't set already, and
    /// it will initialize the player with the given configuration.
    var config: JWPlayerConfiguration? {
        didSet {
            // Load the config, and if necessary, trigger viewDidLoad.
            // If viewDidLoad is not triggered, then playerView is nil.
            guard let config = self.config, view != nil else {
                return
            }
            
            // Initialize the player
            player.configurePlayer(with: config)
        }
    }
    
    // MARK: - Player View Handling
    
    /// This is the view manager in charge of swapping interfaces and managing the view hierarchy.
    /// It contains the `JWPlayerView` object.
    fileprivate var viewManager = PlayerViewManager()
    
    /// A convenience property for accessing the player, via the `viewManager` and `JWPlayerView`.
    fileprivate var player: JWPlayer {
        return viewManager.playerView.player
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
        
        // Setup the time observer. This event is fired as the position updates on the
        // video content, but not the advertising content. If you wish to listen to time
        // events during advertisements, listen to `player.adTimeObserver`
        player.mediaTimeObserver = { [weak viewManager] (time) in
            DispatchQueue.main.async { [weak viewManager] in
                viewManager?.currentTime = time
            }
        }
    }
    
    /// When called, the video will be presented in full screen mode.
    func goFullScreen() {
        // Create the full screen view controller.
        fullScreenViewController = FullScreenPlayerViewController()
        fullScreenViewController!.modalPresentationStyle = .fullScreen
        
        let playerStateBeforeFullscreen = player.getState()
        
        // Assign the full screen view controller as the new controller
        // so the video is put into its view hierarchy, and present it.
        viewManager.setController(fullScreenViewController!)
        present(fullScreenViewController!, animated: true) { [weak self] in
            // Resume playback if the player was playing before entering fullscreen
            if playerStateBeforeFullscreen == .playing {
                self?.player.play()
            }
        }
    }
    
    /// When called, the video returns to normal non-full screen size.
    func exitFullScreen() {
        let playerStateBeforeFullscreen = player.getState()
        // Set this view controller as the new controller, and dismiss the
        // full screen view controller.
        viewManager.setController(self)
        fullScreenViewController?.dismiss(animated: true) { [weak self] in
            // Resume playback if the player was playing before entering fullscreen
            if playerStateBeforeFullscreen == .playing {
                self?.player.play()
            }
        }
    }
}

// MARK: - JWPlayerDelegate

/// We observe callbacks from the JWPlayer object so we know when the video is ready to play
/// and what errors and warnings are being reported. We set this view controller as the JWPlayerDelegate in `viewDidLoad`
extension PlayerViewController: JWPlayerDelegate {
    
    func jwplayerIsReady(_ player: JWPlayer) {
        print("The player is initialized and ready.")
    }
    
    func jwplayer(_ player: JWPlayer, failedWithError code: UInt, message: String) {
        print("JWPlayer Error (\(code)): \(message)")
        reportError(code: code, message: message)
    }
    
    func jwplayer(_ player: JWPlayer, failedWithSetupError code: UInt, message: String) {
        print("JWPlayer Setup Error (\(code)): \(message)")
        reportError(code: code, message: message)
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
    
    private func reportError(code: UInt, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            self.viewManager.interface = .error(code, message)
        }
    }
}

/// We observe player state callbacks from the JWPlayer object so we know when the player's state has changed.
/// We set this view controller as the JWPlayerStateDelegate in `viewDidLoad`
extension PlayerViewController: JWPlayerStateDelegate {
    
    func jwplayerContentWillComplete(_ player: JWPlayer) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, willPlayWithReason reason: JWPlayReason) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, updatedBuffer percent: Double, position time: JWTimeData) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, isBufferingWithReason reason: JWBufferReason) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, updatedCues cues: [JWCue]) {
        // Unimplemented in this example.
    }
    
    func jwplayerContentDidComplete(_ player: JWPlayer) {
        DispatchQueue.main.async { [weak viewManager] in
            // When the video has finished playing, remove the interface.
            // If you wish to be able to play the video again, set the interface
            // to `video` and set the state to `paused`.
            // Or, if you wish to restart the video, simply call `play()` on the player.
            viewManager?.interface = .none
        }
    }
    
    func jwplayer(_ player: JWPlayer, didFinishLoadingWithTime loadTime: TimeInterval) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, isPlayingWithReason reason: JWPlayReason) {
        DispatchQueue.main.async { [weak viewManager] in
            // Set the state to playing, since play began.
            viewManager?.state = .playing
        }
    }
    
    func jwplayer(_ player: JWPlayer, isAttemptingToPlay playlistItem: JWPlayerItem, reason: JWPlayReason) {
        // Unimplemented in this example.
    }
    
    func jwplayer(_ player: JWPlayer, didPauseWithReason reason: JWPauseReason) {
        DispatchQueue.main.async { [weak viewManager] in
            // Set the state to paused, since the video has paused.
            viewManager?.state = .paused
        }
    }
    
    func jwplayer(_ player: JWPlayer, didBecomeIdleWithReason reason: JWIdleReason) {
        DispatchQueue.main.async { [weak viewManager] in
            // While idle (play has not begun) we show the video interface.
            // This allows the use to press the play button or enter full screen.
            // This will display the poster image before play begins.
            // To see the poster image, modify the config in ViewController.swift to set
            // `autostart` to false.
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

/// We observe ad event callbacks from the JWPlayer object so we know when the player's advertising state or information has changed.
/// We set this view controller as the JWAdDelegate in `viewDidLoad`
extension PlayerViewController: JWAdDelegate {
    func jwplayer(_ player: JWPlayer, adEvent event: JWAdEvent) {
        DispatchQueue.main.async { [weak viewManager] in
            switch event.type {
            case .adBreakStart:
                // This event denotes when an advertisement has begun.
                // This is an excellent time to switch to our custom ad interface.
                viewManager?.interface = .ads
            case .adBreakEnd:
                // Once the ad ends, we switch back to the video interface.
                viewManager?.interface = .video
            case .pause:
                // We update the state when the ad is paused.
                viewManager?.state = .paused
            case .play:
                // We update the state when the ad begins playing.
                viewManager?.state = .playing
            default:
                break
            }
        }
    }
}

/// Conforming to InterfaceButtonListener allows us to listen to button taps. This protocol is unique
/// to this example application, and is not part of our SDK.
/// We set this view controller as the button listener in `viewDidLoad`
extension PlayerViewController: InterfaceButtonListener {
    func interfaceButtonTapped(_ button: InterfaceButton) {
        switch button {
        case .play:
            // Begin playing the video when the play button is tapped.
            player.play()
        case .pause:
            // Pause the video when the pause button is tapped.
            player.pause()
        case .enterFullScreen:
            // Enter full screen mode when the user taps the "full screen" button.
            viewManager.windowState = .fullscreen
            goFullScreen()
        case .exitFullScreen:
            // Exit full screen mode when the user taps the "exit full screen" button.
            viewManager.windowState = .normal
            exitFullScreen()
        case .skipAd:
            // Skip the current ad when the user taps the "skip ad" button.
            player.skipAd()
        case .learnMore:
            player.openAdClickthrough()
        }
    }
}
